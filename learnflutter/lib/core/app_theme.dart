import 'package:flutter/material.dart';
import 'package:learnflutter/core/app_text_style.dart';
import 'package:learnflutter/src/app_colors.dart';

/// Custom theme for the app
class AppThemes {
  AppThemes._();

  static Color getfillColorCheckBox(Set<MaterialState> states) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.selected,
      MaterialState.hovered,
      MaterialState.focused,
      MaterialState.disabled,
    };
    if (states.any(interactiveStates.contains)) {
      return AppColors.primary;
    }
    return AppColors.white;
  }

  static Color getCheckColorCheckBox(Set<MaterialState> states) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.selected,
      MaterialState.hovered,
      MaterialState.focused,
      MaterialState.disabled,
    };
    if (states.any(interactiveStates.contains)) {
      return Colors.white;
    }
    return Colors.red.lighter;
  }

  static Color backGroundColorSearchbar(Set<MaterialState> states) {
    if (states.contains(MaterialState.focused)) {
      return AppColors.white;
    } else if (states.contains(MaterialState.selected)) {
      return AppColors.white;
    } else if (states.contains(MaterialState.disabled)) {
      return AppColors.grey.lighter;
    }
    return AppColors.white;
  }

  static Color? backGroundTextButton(Set<MaterialState> states) {
    (Set<MaterialState> states) {
      if (states.contains(MaterialState.disabled)) {
        return AppColors.primary.lighter;
      }
    };
    return AppColors.primary; // Defer to the widget's default.
  }

  static TextStyle? textStyleTextButton(Set<MaterialState> states) {
    (Set<MaterialState> states) {
      if (states.contains(MaterialState.disabled)) {
        return AppTextStyles.themeLabelMedium.copyWith(color: Colors.white.lighter, fontWeight: FontWeight.w700);
      }
    };
    return AppTextStyles.themeLabelMedium.copyWith(color: Colors.white.lighter, fontWeight: FontWeight.w700);
  }

  static TextStyle? hintStyleSearchBar(Set<MaterialState> states) {
    return AppTextStyles.themeTitleMedium.copyWith(color: AppColors.primaryText.lighter);
  }

  static TextStyle? textStyleSearchBar(Set<MaterialState> states) {
    return AppTextStyles.themeTitleMedium.copyWith(color: AppColors.primaryText);
  }

  static OutlinedBorder? shapeBorderSearchBar(Set<MaterialState> states) {
    if (states.contains(MaterialState.focused)) {
      return RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(
          color: AppColors.primary,
          width: 1,
        ),
      );
    }
    return RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(
        color: AppColors.white,
        width: 1,
      ),
    );
  }

  static EdgeInsets? paddingSearchBar(Set<MaterialState> states) {
    return const EdgeInsets.all(8);
  }

  static OutlinedBorder shapeBorder(bool isCicre, double borderRadius) {
    if (isCicre) {
      return const OvalBorder();
    }
    return RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(borderRadius),
    );
  }

  static Color fillColorRadio(Set<MaterialState> states) {
    if (states.contains(MaterialState.focused)) {
      return AppColors.primary;
    } else if (states.contains(MaterialState.selected)) {
      return AppColors.primary;
    } else if (states.contains(MaterialState.disabled)) {
      return AppColors.primary.lighter;
    }
    return AppColors.primary;
  }

  static Color chipThemeColor(Set<MaterialState> states) {
    if (states.contains(MaterialState.focused)) {
      return AppColors.primary;
    } else if (states.contains(MaterialState.selected)) {
      return AppColors.primary;
    } else if (states.contains(MaterialState.disabled)) {
      return AppColors.primary.lighter;
    }
    return AppColors.white;
  }

  static OutlinedBorder? shapeBorderChipThemer() {
    return RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(
        color: AppColors.white,
        width: 1,
      ),
    );
  }

  static final primaryTheme = ThemeData(
      textTheme: TextTheme(
        displayLarge: AppTextStyles.themeDisplayLarge,
        displayMedium: AppTextStyles.themeDisplayMedium,
        displaySmall: AppTextStyles.themeDisplaySmall,
        headlineLarge: AppTextStyles.themeHeadlineLarge,
        headlineMedium: AppTextStyles.themeHeadlineMedium,
        headlineSmall: AppTextStyles.themeHeadlineSmall,
        titleLarge: AppTextStyles.themeTitleLarge,
        titleMedium: AppTextStyles.themeTitleMedium,
        titleSmall: AppTextStyles.themeTitleSmall,
        bodyLarge: AppTextStyles.themeBodyLarge,
        bodyMedium: AppTextStyles.themeBodyMedium,
        bodySmall: AppTextStyles.themeBodySmall,
        labelLarge: AppTextStyles.themeLabelLarge,
        labelMedium: AppTextStyles.themeLabelMedium,
        labelSmall: AppTextStyles.themeLabelSmall,
      ),
      hintColor: AppColors.hintTextLabel,
      primaryColor: AppColors.white,
      highlightColor: Colors.transparent,
      indicatorColor: AppColors.greyBlue,
      unselectedWidgetColor: AppColors.lightGrey,
      useMaterial3: true,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        titleTextStyle: AppTextStyles.themeHeadlineMedium,
        backgroundColor: AppColors.white,
        toolbarHeight: 44,
      ),
      switchTheme: SwitchThemeData(
        trackOutlineColor: MaterialStateProperty.resolveWith<Color?>(
          (Set<MaterialState> states) {
            return AppColors.grey.lighter; // Defer to the widget's default.
          },
        ),
        trackOutlineWidth: MaterialStateProperty.resolveWith<double?>(
          (Set<MaterialState> states) {
            return 60; // Defer to the widget's default.
          },
        ),
        thumbColor: MaterialStateProperty.resolveWith<Color?>(
          (Set<MaterialState> states) {
            return AppColors.white; // Defer to the widget's default.
          },
        ),
        trackColor: MaterialStateProperty.resolveWith<Color?>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.selected)) {
              return AppColors.green;
            } else if (states.contains(MaterialState.disabled)) {
              return AppColors.grey.lighter;
            }
            return AppColors.grey.lighter; // Defer to the widget's default.
          },
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith(getfillColorCheckBox),
        checkColor: MaterialStateProperty.resolveWith(getCheckColorCheckBox),
        side: const BorderSide(width: 2, color: AppColors.primary),
        shape: shapeBorder(false, 6),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith<Color?>(backGroundTextButton),
          textStyle: MaterialStateProperty.resolveWith(textStyleTextButton),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith<Color?>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.focused)) return AppColors.white;
              return AppColors.primary; // Defer to the widget's default.
            },
          ),
          textStyle: MaterialStateProperty.resolveWith(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.focused)) return AppTextStyles.themeLabelMedium;
              return AppTextStyles.themeLabelMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w700); // Defer to the widget's default.
            },
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith<Color?>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.focused)) return AppColors.white;
              return AppColors.primary; // Defer to the widget's default.
            },
          ),
          textStyle: MaterialStateProperty.resolveWith(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.focused)) return AppTextStyles.themeLabelMedium;
              return AppTextStyles.themeLabelMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w700); // Defer to the widget's default.
            },
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith<Color?>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.focused)) return Colors.transparent;
              return Colors.transparent; // Defer to the widget's default.
            },
          ),
          iconColor: MaterialStateProperty.resolveWith<Color?>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.focused)) return AppColors.black;
              return AppColors.black; // Defer to the widget's default.
            },
          ),
        ),
      ),
      searchBarTheme: SearchBarThemeData(
        backgroundColor: MaterialStateProperty.resolveWith<Color?>(backGroundColorSearchbar),
        hintStyle: MaterialStateProperty.resolveWith(hintStyleSearchBar),
        shape: MaterialStateProperty.resolveWith(shapeBorderSearchBar),
        textStyle: MaterialStateProperty.resolveWith(textStyleSearchBar),
        shadowColor: MaterialStateProperty.resolveWith((backGroundColorSearchbar)),
        overlayColor: MaterialStateProperty.resolveWith((backGroundColorSearchbar)),
        padding: MaterialStateProperty.resolveWith((paddingSearchBar)),
      ),
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith(fillColorRadio),
      ),
      iconTheme: const IconThemeData(
        color: AppColors.red,
        fill: 1,
        grade: 0.5,
        opacity: 0.6,
        opticalSize: 100,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        modalElevation: 1,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        clipBehavior: Clip.hardEdge,
      ),
      dialogTheme: DialogTheme(
        iconColor: AppColors.primary,
        backgroundColor: AppColors.white,
        elevation: 1,
        titleTextStyle: AppTextStyles.themeTitleLarge,
        actionsPadding: const EdgeInsets.all(8),
        contentTextStyle: AppTextStyles.themeBodyMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.transparent,
        checkmarkColor: AppColors.white,
        selectedColor: AppColors.primary,
        color: MaterialStateProperty.resolveWith(chipThemeColor),
        deleteIconColor: AppColors.red,
        disabledColor: AppColors.red.lighter,
        labelPadding: const EdgeInsets.all(8),
        labelStyle: AppTextStyles.themeBodyMedium,
        shape: shapeBorderChipThemer(),
        side: const BorderSide(width: 2, color: AppColors.primary),
        iconTheme: const IconThemeData(
          color: AppColors.red,
          fill: 1,
          grade: 0.5,
          opacity: 0.6,
          opticalSize: 100,
        ),
      ),
      dropdownMenuTheme: const DropdownMenuThemeData(menuStyle: MenuStyle()),
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.black, // Màu sắc chính được nhấn mạnh trên bề mặt
        onPrimary: AppColors.primaryText, //Màu sắc Văn bản và biểu tượng
        primaryContainer: AppColors.yellowBackground, // Màu tô nổi bật trên bề mặt, dành cho các thành phần chính
        onPrimaryContainer: AppColors.grey, //Văn bản và biểu tượng đối với thành phần chính
        secondary: Color(0xFFBBBBBB), //Màu sắc ít nổi bật hơn trên bề mặt
        onSecondary: Color(0xFFEAEAEA), //Màu sắc Văn bản và biểu tượng
        secondaryContainer: Color(0xFFBBBBBB), // Màu tô ít nổi bật trên bề mặt, dành cho các thành phần chính
        onSecondaryContainer: Color(0xFFBBBBBB), //Văn bản và biểu tượng đối với thành phần chính
        tertiary: Color(0xFF54B435), // Màu sắc thứ 3 được nhấn mạnh trên bề mặt
        onTertiary: Color(0xFF54B435), //Màu sắc Văn bản và biểu tượng
        tertiaryContainer: Color(0xFF54B435), // Màu tô ít nổi bật thứ 3 trên bề mặt, dành cho các thành phần chính
        onTertiaryContainer: Color(0xFF54B435), //Màu sắc Văn bản và biểu tượng
        error: Color(0xFFF32424), //Màu sắc thu hút sự chú ý trên bề mặt của phần tô, biểu tượng và văn bản, biểu thị mức độ khẩn cấp
        onError: AppColors.red, //Văn bản và biểu tượng chống lỗi
        errorContainer: AppColors.red, // Màu tô thu hút sự chú ý trên bề mặt
        onErrorContainer: AppColors.red, // Văn bản và biểu tượng chống lại vùng chứa lỗi
        surface: Color(0xFF54B435), //Màu mặc định cho nền
        onSurface: Color(0xFF54B435), //Văn bản và biểu tượng trên nền
        onSurfaceVariant: Color(0xFF54B435), //Màu nhấn mạnh hơn cho văn bản và biểu tượng
        inversePrimary: AppColors.backButtonColor, // Các phần tử có thể thao tác, chẳng hạn như nút văn bản, trên bề mặt nghịch đảo
        inverseSurface: AppColors.backButtonColor, //Nền lấp đầy cho các phần tử tương phản với bề mặt
        onInverseSurface: AppColors.backButtonColor, // Văn bản và biểu tượng trên bề mặt nghịch đảo
        outline: AppColors.backButtonColor, //Các ranh giới quan trọng, chẳng hạn như phác thảo trường văn bản
        outlineVariant: AppColors.background_02, //Các yếu tố trang trí, chẳng hạn như dải phân cách
        background: Color(0xFFF1F2F3),
        onBackground: Color(0xFFFFFFFF),
      ));
}
