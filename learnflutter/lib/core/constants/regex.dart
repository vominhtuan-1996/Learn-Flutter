/// Lớp ConstantsRegex tập trung quản lý các biểu thức chính quy (Regular Expressions) được sử dụng để kiểm tra tính hợp lệ của dữ liệu đầu vào.
/// Nó bao gồm các quy tắc kiểm tra định dạng email, số điện thoại, số thập phân và cả các ký tự đặc biệt trong tiếng Việt.
/// Việc sử dụng Regex giúp đảm bảo dữ liệu được thu thập từ người dùng luôn nhất quán và đúng định dạng trước khi được xử lý tiếp.
/// Các hằng số này có thể được tái sử dụng ở bất kỳ đâu trong ứng dụng để duy trì một cơ chế kiểm tra đồng nhất.
class ConstantsRegex {
  ConstantsRegex._();

  /// validCharacters xác định các ký tự được phép sử dụng, bao gồm chữ cái, chữ số, gạch dưới và toàn bộ bảng mã tiếng Việt có dấu.
  /// Nó thường được dùng để validate các trường nhập liệu tên người dùng hoặc các đoạn văn bản mô tả cơ bản.
  /// Biểu thức này đảm bảo ứng dụng hỗ trợ tốt nội dung tiếng Việt mà không gặp lỗi về mã hóa hoặc ký tự không hợp lệ.
  static final validCharacters = RegExp(
      r'^[a-zA-Z0-9_ÀÁÂÃÈÉÊẾÌÍÒÓÔÕÙÚĂĐĨŨƠàáâãèéêếìíòóôõùúăđĩũơƯĂẠẢẤẦẨẪẬẮẰẲẴẶẸẺẼỀỀỂưăạảấầẩẫậắằẳẵặẹẻẽềềểỄỆỈỊỌỎỐỒỔỖỘỚỜỞỠỢỤỦỨỪễệỉịọỏốồổỗộớờởỡợụủứừỬỮỰỲỴÝỶỸửữựỳỵỷỹ\ ]+');
  static const vietnamese = 'aAeEoOuUiIdDyY';
  static final vietnameseRegex = <RegExp>[
    RegExp(r'à|á|ạ|ả|ã|â|ầ|ấ|ậ|ẩ|ẫ|ă|ằ|ắ|ặ|ẳ|ẵ'),
    RegExp(r'À|Á|Ạ|Ả|Ã|Â|Ầ|Ấ|Ậ|Ẩ|Ẫ|Ă|Ằ|Ắ|Ặ|Ẳ|Ẵ'),
    RegExp(r'è|é|ẹ|ẻ|ẽ|ê|ề|ế|ệ|ể|ễ'),
    RegExp(r'È|É|Ẹ|Ẻ|Ẽ|Ê|Ề|Ế|Ệ|Ể|Ễ'),
    RegExp(r'ò|ó|ọ|ỏ|õ|ô|ồ|ố|ộ|ổ|ỗ|ơ|ờ|ớ|ợ|ở|ỡ'),
    RegExp(r'Ò|Ó|Ọ|Ỏ|Õ|Ô|Ồ|Ố|Ộ|Ổ|Ỗ|Ơ|Ờ|Ớ|Ợ|Ở|Ỡ'),
    RegExp(r'ù|ú|ụ|ủ|ũ|ư|ừ|ứ|ự|ử|ữ'),
    RegExp(r'Ù|Ú|Ụ|Ủ|Ũ|Ư|Ừ|Ứ|Ự|Ử|Ữ'),
    RegExp(r'ì|í|ị|ỉ|ĩ'),
    RegExp(r'Ì|Í|Ị|Ỉ|Ĩ'),
    RegExp(r'đ'),
    RegExp(r'Đ'),
    RegExp(r'ỳ|ý|ỵ|ỷ|ỹ'),
    RegExp(r'Ỳ|Ý|Ỵ|Ỷ|Ỹ')
  ];

  // regex Email
  static final regexValidationEmail = RegExp(
      r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$');

  // số thập phân nguyên dương
  static final regexDouble = RegExp(r'^\d+[.,]?\d*');

  // số thập phân có 2 số nguyên sau dấu ","
  static final regexDoubleXX = RegExp(r'^\d+[.,]?\d{0,2}');

  // số thập phân có 2 số nguyên âm sau dấu ","
  static final regexNegativeDoubleXX = RegExp(r'^[-]?\d*[.,]?\d{0,2}');

  // số nguyên
  static final regexNumber = RegExp(r'^\d+');

  // số nguyên not zero
  static final regexNumberNotZero = RegExp(r'^[1-9]\d*');

  // phone numbber
  static final regexPhoneNumbber = RegExp(r'^[0]\d{0,9}');

  // dd

  static final regexDD = RegExp(r'^0[1-9]|[12][0-9]|3[01]');

  static final regexMM = RegExp(r'^0[1-9]|1[012]');
}
