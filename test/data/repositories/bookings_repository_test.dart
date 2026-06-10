import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:swades_hackathon_app/data/api/bookings_api.dart';
import 'package:swades_hackathon_app/data/local/bookings_cache.dart';
import 'package:swades_hackathon_app/data/repositories/bookings_repository.dart';
import 'package:swades_hackathon_app/data/utils/failure.dart';
import 'package:swades_hackathon_app/data/utils/result.dart';

class _MockBookingsApi extends Mock implements BookingsApi {}

class _MockBookingsCache extends Mock implements BookingsCache {}

void main() {
  late _MockBookingsApi api;
  late _MockBookingsCache cache;
  late BookingsRepository repo;

  setUp(() {
    api = _MockBookingsApi();
    cache = _MockBookingsCache();
    repo = BookingsRepository(bookingsApi: api, cache: cache);
  });

  group('createBooking 409 mapping (the concurrency story)', () {
    test(
        'maps DioException 409 from API into a typed SlotTakenFailure '
        '— this is the wire that carries the Postgres 23505 unique-violation '
        'all the way to the UI', () async {
      // arrange: API responds the way our NestJS handler does on 23505 →
      // 409 with body {"message":"SLOT_TAKEN"}
      when(
        () => api.createBooking(
          venueId: any(named: 'venueId'),
          slotStartUtc: any(named: 'slotStartUtc'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/bookings'),
          response: Response(
            requestOptions: RequestOptions(path: '/bookings'),
            statusCode: 409,
            data: {
              'statusCode': 409,
              'message': 'SLOT_TAKEN',
              'error': 'Conflict',
            },
          ),
          type: DioExceptionType.badResponse,
        ),
      );

      // act
      final result = await repo.createBooking(
        venueId: 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
        slotStartUtc: '2026-06-11T11:30:00.000Z',
      );

      // assert
      expect(result, isA<FailureResult>());
      final failure = (result as FailureResult).failure;
      expect(failure, isA<SlotTakenFailure>());
      expect(failure.message, contains('just taken'));
    });

    test('maps connection timeout into NetworkFailure', () async {
      when(
        () => api.createBooking(
          venueId: any(named: 'venueId'),
          slotStartUtc: any(named: 'slotStartUtc'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/bookings'),
          type: DioExceptionType.connectionTimeout,
        ),
      );

      final result = await repo.createBooking(
        venueId: 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
        slotStartUtc: '2026-06-11T11:30:00.000Z',
      );

      expect(result, isA<FailureResult>());
      expect((result as FailureResult).failure, isA<NetworkFailure>());
    });

    test('maps 500 into ServerFailure', () async {
      when(
        () => api.createBooking(
          venueId: any(named: 'venueId'),
          slotStartUtc: any(named: 'slotStartUtc'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/bookings'),
          response: Response(
            requestOptions: RequestOptions(path: '/bookings'),
            statusCode: 500,
            data: {'message': 'boom'},
          ),
          type: DioExceptionType.badResponse,
        ),
      );

      final result = await repo.createBooking(
        venueId: 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
        slotStartUtc: '2026-06-11T11:30:00.000Z',
      );

      expect((result as FailureResult).failure, isA<ServerFailure>());
    });
  });

  group('listUserBookings offline fallback', () {
    test(
        'on NetworkFailure, returns Success(isFromCache: true) when cache has '
        'data — the offline read-cache bonus path', () async {
      when(() => api.listUserBookings(any())).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/users/x/bookings'),
          type: DioExceptionType.connectionError,
        ),
      );
      final cachedRow = {
        'id': 'b1',
        'user_id': 'u1',
        'venue_id': 'v1',
        'slot_start_utc': '2026-06-11T10:30:00.000Z',
        'status': 'confirmed',
        'created_at': '2026-06-10T15:00:00.000Z',
        'cancelled_at': null,
        'venue': null,
      };
      when(() => cache.load('u1')).thenReturn([cachedRow]);
      when(() => cache.loadStamp('u1'))
          .thenReturn(DateTime.utc(2026, 6, 10, 16));

      final result = await repo.listUserBookings('u1');

      expect(result, isA<Success>());
      final success = result as Success;
      expect(success.isFromCache, isTrue);
      expect(success.cacheStamp, isNotNull);
      expect(success.data, hasLength(1));
    });

    test('on success, persists to cache and returns isFromCache: false',
        () async {
      when(() => api.listUserBookings('u1')).thenAnswer((_) async => [
            {
              'id': 'b1',
              'user_id': 'u1',
              'venue_id': 'v1',
              'slot_start_utc': '2026-06-11T10:30:00.000Z',
              'status': 'confirmed',
              'created_at': '2026-06-10T15:00:00.000Z',
              'cancelled_at': null,
              'venue': null,
            }
          ]);
      when(() => cache.save(any(), any())).thenAnswer((_) async {});

      final result = await repo.listUserBookings('u1');

      expect(result, isA<Success>());
      expect((result as Success).isFromCache, isFalse);
      verify(() => cache.save('u1', any())).called(1);
    });
  });
}
