import 'package:swades_hackathon_app/data/api/venues_api.dart';
import 'package:swades_hackathon_app/data/models/slot.dart';
import 'package:swades_hackathon_app/data/models/venue.dart';
import 'package:swades_hackathon_app/data/repositories/_dio_failure_mapper.dart';
import 'package:swades_hackathon_app/data/utils/result.dart';

class VenuesRepository {
  VenuesRepository({required VenuesApi venuesApi}) : _api = venuesApi;

  final VenuesApi _api;

  Future<Result<List<Venue>>> listVenues() async {
    try {
      final raw = await _api.listVenues();
      return Success(raw.map(Venue.fromJson).toList());
    } catch (e) {
      return FailureResult(mapDioError(e));
    }
  }

  Future<Result<List<Slot>>> listSlots({
    required String venueId,
    required String date,
  }) async {
    try {
      final raw = await _api.listSlots(venueId: venueId, date: date);
      return Success(raw.map(Slot.fromJson).toList());
    } catch (e) {
      return FailureResult(mapDioError(e));
    }
  }
}
