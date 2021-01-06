import 'adapters/dio_adapter_mockito_test.dart' as dio_adapter_mockito_test;
import 'adapters/dio_adapter_test.dart' as dio_adapter_test;
import 'interceptors/dio_interceptor_test.dart' as dio_interceptor_test;
import 'matchers/any_test.dart' as any_test;
import 'matchers/boolean_test.dart' as boolean_test;
import 'matchers/decimal_test.dart' as decimal_test;
import 'matchers/integer_test.dart' as integer_test;
import 'matchers/number_test.dart' as number_test;
import 'matchers/regexp_test.dart' as regexp_test;
import 'matchers/string_test.dart' as string_test;
import 'matches_request_test.dart' as matches_request_test;
import 'utils_test.dart' as utils_test;

void main() {
  // Adapters.
  dio_adapter_mockito_test.main();
  dio_adapter_test.main();

  // Interceptors.
  dio_interceptor_test.main();

  // Matchers.
  any_test.main();
  boolean_test.main();
  decimal_test.main();
  integer_test.main();
  number_test.main();
  regexp_test.main();
  string_test.main();

  // Matches request.
  matches_request_test.main();

  // Utils.
  utils_test.main();
}
