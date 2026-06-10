class Endpoint {
  Endpoint._();

  static const String baseUrl = 'https://quickslot-api.onrender.com';

  static const String users = '/users';
  static const String venues = '/venues';
  static const String bookings = '/bookings';

  static String venueSlots(String venueId) => '/venues/$venueId/slots';
  static String userBookings(String userId) => '/users/$userId/bookings';
  static String bookingById(String id) => '/bookings/$id';
}
