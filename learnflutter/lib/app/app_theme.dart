import 'package:flutter/material.dart';
import 'package:learnflutter/app/app_text_style.dart';
import 'package:learnflutter/utils_helper/extension/extension_context.dart';
import 'package:learnflutter/modules/setting/state/setting_state.dart';
import 'package:learnflutter/app/app_colors.dart';

/// Custom theme for the app
class AppThemes {
  AppThemes._();

  static Color getfillColorCheckBox(Set<WidgetState> states) {
    const Set<WidgetState> interactiveStates = <WidgetState>{
      WidgetState.selected,
      WidgetState.hovered,
      WidgetState.focused,
      WidgetState.disabled,
    };
    if (states.any(interactiveStates.contains)) {
      return AppColors.primary;
    }
    return AppColors.white;
  }

  static Color getCheckColorCheckBox(Set<WidgetState> states) {
    const Set<WidgetState> interactiveStates = <WidgetState>{
      WidgetState.selected,
      WidgetState.hovered,
      WidgetState.focused,
      WidgetState.disabled,
    };
    if (states.any(interactiveStates.contains)) {
      return Colors.white;
    }
    return Colors.red.lighter;
  }

  static Color backGroundColorSearchbar(Set<WidgetState> states) {
    if (states.contains(WidgetState.focused)) {
      return AppColors.white;
    } else if (states.contains(WidgetState.selected)) {
      return AppColors.white;
    } else if (states.contains(WidgetState.disabled)) {
      return AppColors.grey.lighter;
    }
    return AppColors.white;
  }

  static Color? backGroundTextButton(Set<WidgetState> states) {
    (Set<WidgetState> states) {
      if (states.contains(WidgetState.disabled)) {
        return AppColors.primary.lighter;
      }
    };
    return AppColors.primary; // Defer to the widget's default.
  }

  static TextStyle? textStyleTextButton(Set<WidgetState> states) {
    (Set<WidgetState> states) {
      if (states.contains(WidgetState.disabled)) {
        return AppTextStyles.themeLabelMedium.copyWith(color: Colors.white.lighter, fontWeight: FontWeight.w700);
      }
    };
    return AppTextStyles.themeLabelMedium.copyWith(color: Colors.white.lighter, fontWeight: FontWeight.w700);
  }

  static TextStyle? hintStyleSearchBar(Set<WidgetState> states) {
    return AppTextStyles.themeTitleMedium.copyWith(color: AppColors.primaryText.lighter);
  }

  static TextStyle? textStyleSearchBar(Set<WidgetState> states) {
    return AppTextStyles.themeTitleMedium.copyWith(color: AppColors.primaryText);
  }

  static OutlinedBorder? shapeBorderSearchBar(Set<WidgetState> states) {
    if (states.contains(WidgetState.focused)) {
      return RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(
          color: AppColors.primary,
          width: 1.6,
        ),
      );
    }
    return RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
      side: const BorderSide(
        color: AppColors.lightGrey,
        width: 1.6,
      ),
    );
  }

  static EdgeInsets? paddingSearchBar(Set<WidgetState> states) {
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

  static Color fillColorRadio(Set<WidgetState> states) {
    if (states.contains(WidgetState.focused)) {
      return AppColors.primary;
    } else if (states.contains(WidgetState.selected)) {
      return AppColors.primary;
    } else if (states.contains(WidgetState.disabled)) {
      return AppColors.primary.lighter;
    }
    return AppColors.primary;
  }

  static Color chipThemeColor(Set<WidgetState> states) {
    if (states.contains(WidgetState.focused)) {
      return AppColors.white;
    } else if (states.contains(WidgetState.selected)) {
      return AppColors.primary;
    } else if (states.contains(WidgetState.disabled)) {
      return AppColors.primary.lighter;
    }
    return AppColors.white;
  }

  static OutlinedBorder? shapeBorderChipThemer() {
    return RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
      side: const BorderSide(
        color: AppColors.white,
        width: 1,
      ),
    );
  }

  static ThemeData primaryTheme(BuildContext context, SettingThemeState state) => ThemeData(
        textTheme: TextTheme(
          displayLarge: AppTextStyles.themeDisplayLarge.copyWith(fontSize: state.scaleText! * 57),
          displayMedium: AppTextStyles.themeDisplayMedium.copyWith(fontSize: state.scaleText! * 45),
          displaySmall: AppTextStyles.themeDisplaySmall.copyWith(fontSize: state.scaleText! * 36),
          headlineLarge: AppTextStyles.themeHeadlineLarge.copyWith(fontSize: state.scaleText! * 32),
          headlineMedium: AppTextStyles.themeHeadlineMedium.copyWith(fontSize: state.scaleText! * 28),
          headlineSmall: AppTextStyles.themeHeadlineSmall.copyWith(fontSize: state.scaleText! * 24),
          titleLarge: AppTextStyles.themeTitleLarge.copyWith(fontSize: state.scaleText! * 22),
          titleMedium: AppTextStyles.themeTitleMedium.copyWith(fontSize: state.scaleText! * 16),
          titleSmall: AppTextStyles.themeTitleSmall.copyWith(fontSize: state.scaleText! * 14),
          bodyLarge: AppTextStyles.themeBodyLarge.copyWith(fontSize: state.scaleText! * 16),
          bodyMedium: AppTextStyles.themeBodyMedium.copyWith(fontSize: state.scaleText! * 14),
          bodySmall: AppTextStyles.themeBodySmall.copyWith(fontSize: state.scaleText! * 12),
          labelLarge: AppTextStyles.themeLabelLarge.copyWith(fontSize: state.scaleText! * 14),
          labelMedium: AppTextStyles.themeLabelMedium.copyWith(fontSize: state.scaleText! * 12),
          labelSmall: AppTextStyles.themeLabelSmall.copyWith(fontSize: state.scaleText! * 11),
        ),
        hintColor: AppColors.hintTextLabel,
        primaryColor: AppColors.white,
        highlightColor: Colors.transparent,
        indicatorColor: AppColors.greyBlue,
        unselectedWidgetColor: AppColors.lightGrey,
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          centerTitle: true,
          titleTextStyle: AppTextStyles.themeHeadlineMedium.copyWith(fontSize: state.scaleText! * 28),
          backgroundColor: state.light ?? false ? AppColors.white : AppColors.black,
          toolbarHeight: 44,
        ),
        switchTheme: SwitchThemeData(
          trackOutlineColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) {
              return AppColors.grey.lighter; // Defer to the widget's default.
            },
          ),
          trackOutlineWidth: WidgetStateProperty.resolveWith<double?>(
            (Set<WidgetState> states) {
              return 0.5; // Defer to the widget's default.
            },
          ),
          thumbColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.selected)) {
                return AppColors.primary;
              }
              return AppColors.white; // Defer to the widget's default.
            },
          ),
          trackColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.disabled)) {
                return AppColors.grey.lighter;
              }
              if (states.contains(WidgetState.selected)) {
                return AppColors.green2;
              }

              return AppColors.grey.lighter; // Defer to the widget's default.
            },
          ),
          thumbIcon: WidgetStateProperty.resolveWith<Icon>(
            (states) {
              return const Icon(
                Icons.check_rounded,
                color: Colors.white,
              );
            },
          ),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.resolveWith(getfillColorCheckBox),
          checkColor: WidgetStateProperty.resolveWith(getCheckColorCheckBox),
          side: const BorderSide(width: 2, color: AppColors.primary),
          shape: shapeBorder(false, 6),
        ),
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith<Color?>(backGroundTextButton),
            textStyle: WidgetStateProperty.resolveWith(
              (Set<WidgetState> states) {
                if (states.contains(WidgetState.focused)) return AppTextStyles.themeBodyMedium.copyWith(fontSize: state.scaleText! * 12);
                return AppTextStyles.themeBodyMedium.copyWith(fontSize: state.scaleText! * 12);
              },
            ),
            padding: WidgetStateProperty.resolveWith(
              (states) {
                return EdgeInsets.symmetric(horizontal: 8);
              },
            ),
            overlayColor: WidgetStateProperty.resolveWith(
              (states) {
                return AppColors.primary.withOpacity(0.2);
              },
            ),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith<Color?>(
              (Set<WidgetState> states) {
                if (states.contains(WidgetState.focused)) return AppColors.white;
                return AppColors.primary; // Defer to the widget's default.
              },
            ),
            textStyle: WidgetStateProperty.resolveWith(
              (Set<WidgetState> states) {
                if (states.contains(WidgetState.focused)) return AppTextStyles.themeLabelMedium.copyWith(fontSize: state.scaleText! * 12);
                return AppTextStyles.themeLabelMedium.copyWith(fontSize: state.scaleText! * 12);
              },
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith<Color?>(
              (Set<WidgetState> states) {
                if (states.contains(WidgetState.focused)) return AppColors.white;
                return AppColors.primary; // Defer to the widget's default.
              },
            ),
            textStyle: WidgetStateProperty.resolveWith(
              (Set<WidgetState> states) {
                if (states.contains(WidgetState.focused)) return AppTextStyles.themeLabelMedium;
                return AppTextStyles.themeLabelMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w700); // Defer to the widget's default.
              },
            ),
          ),
        ),
        iconButtonTheme: IconButtonThemeData(
          style: ButtonStyle(backgroundColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.focused)) return Colors.transparent;
              return Colors.transparent; // Defer to the widget's default.
            },
          ), iconColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.focused)) return AppColors.black;
              return state.light ?? false ? AppColors.black : AppColors.white; // Defer to the widget's default.
            },
          ), shape: WidgetStateProperty.resolveWith(
            (states) {
              return RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              );
            },
          )),
        ),
        searchBarTheme: SearchBarThemeData(
          backgroundColor: WidgetStateProperty.resolveWith<Color?>(backGroundColorSearchbar),
          hintStyle: WidgetStateProperty.resolveWith(hintStyleSearchBar),
          shape: WidgetStateProperty.resolveWith(shapeBorderSearchBar),
          textStyle: WidgetStateProperty.resolveWith(textStyleSearchBar),
          shadowColor: WidgetStateProperty.resolveWith((backGroundColorSearchbar)),
          overlayColor: WidgetStateProperty.resolveWith((backGroundColorSearchbar)),
          padding: WidgetStateProperty.resolveWith((paddingSearchBar)),
        ),
        radioTheme: RadioThemeData(
          fillColor: WidgetStateProperty.resolveWith(fillColorRadio),
        ),
        iconTheme: const IconThemeData(
          color: AppColors.primary,
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
          actionsPadding: EdgeInsets.zero,
          contentTextStyle: AppTextStyles.themeBodyMedium,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: Colors.transparent,
          checkmarkColor: AppColors.white,
          selectedColor: AppColors.primary,
          color: WidgetStateProperty.resolveWith(chipThemeColor),
          deleteIconColor: AppColors.red,
          disabledColor: AppColors.red.lighter,
          labelPadding: const EdgeInsets.symmetric(horizontal: 8),
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
        badgeTheme: BadgeThemeData(
          alignment: AlignmentDirectional.center,
          largeSize: 24,
          backgroundColor: AppColors.red,
          smallSize: 24,
          textColor: AppColors.primaryText,
          textStyle: AppTextStyles.themeLabelMedium.copyWith(fontSize: state.scaleText! * 12),
        ),
        dropdownMenuTheme: const DropdownMenuThemeData(menuStyle: MenuStyle()),
        colorScheme: ColorScheme(
          brightness: state.light ?? false ? Brightness.light : Brightness.dark,
          primary: const Color(0xFF21005D), // Màu sắc chính được nhấn mạnh trên bề mặt,
          onPrimary: AppColors.primaryText, //Màu sắc Văn bản và biểu tượng
          primaryContainer: AppColors.primary, // Màu tô nổi bật trên bề mặt, dành cho các thành phần chính
          onPrimaryContainer: AppColors.grey, //Văn bản và biểu tượng đối với thành phần chính
          secondary: const Color(0xFF1D192B), //Màu sắc ít nổi bật hơn trên bề mặt
          onSecondary: AppColors.blue.withOpacity(0.8), //Màu sắc Văn bản và biểu tượng
          secondaryContainer: AppColors.blue.withOpacity(0.6), // Màu tô ít nổi bật trên bề mặt, dành cho các thành phần chính
          onSecondaryContainer: AppColors.blue.withOpacity(0.4), //Văn bản và biểu tượng đối với thành phần chính
          tertiary: const Color(0xFFFFD8E4), // Màu sắc thứ 3 được nhấn mạnh trên bề mặt
          onTertiary: AppColors.blue.withOpacity(0.8), //Màu sắc Văn bản và biểu tượng
          tertiaryContainer: AppColors.blue.withOpacity(0.6), // Màu tô ít nổi bật thứ 3 trên bề mặt, dành cho các thành phần chính
          onTertiaryContainer: AppColors.blue.withOpacity(0.4), //Màu sắc Văn bản và biểu tượng
          error: const Color(0xFFF32424), //Màu sắc thu hút sự chú ý trên bề mặt của phần tô, biểu tượng và văn bản, biểu thị mức độ khẩn cấp
          onError: AppColors.red, //Văn bản và biểu tượng chống lỗi
          errorContainer: AppColors.red, // Màu tô thu hút sự chú ý trên bề mặt
          onErrorContainer: AppColors.red, // Văn bản và biểu tượng chống lại vùng chứa lỗi
          surface: AppColors.white, //Màu mặc định cho nền
          onSurface: const Color(0xFF6750A4), //Văn bản và biểu tượng trên nền
          onSurfaceVariant: AppColors.black.withOpacity(0.6), //Màu nhấn mạnh hơn cho văn bản và biểu tượng
          inversePrimary: AppColors.backButtonColor, // Các phần tử có thể thao tác, chẳng hạn như nút văn bản, trên bề mặt nghịch đảo
          inverseSurface: AppColors.backButtonColor, //Nền lấp đầy cho các phần tử tương phản với bề mặt
          onInverseSurface: AppColors.backButtonColor, // Văn bản và biểu tượng trên bề mặt nghịch đảo
          outline: AppColors.backButtonColor, //Các ranh giới quan trọng, chẳng hạn như phác thảo trường văn bản
          outlineVariant: AppColors.background_02, //state.light ?? false ? const Color(0xFFFFFFFF) : AppColors.black,
        ),
        datePickerTheme: DatePickerThemeData(
          backgroundColor: AppColors.white,
          cancelButtonStyle: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith<Color?>(backGroundTextButton),
            textStyle: WidgetStateProperty.resolveWith(
              (Set<WidgetState> states) {
                if (states.contains(WidgetState.focused)) return AppTextStyles.themeBodyMedium.copyWith(fontSize: state.scaleText! * 12);
                return AppTextStyles.themeBodyMedium.copyWith(fontSize: state.scaleText! * 12);
              },
            ),
          ),
          dayShape: const WidgetStatePropertyAll(CircleBorder()),
          dayBackgroundColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.selected)) {
                return AppColors.primary;
              } else if (states.contains(WidgetState.focused)) {
                return AppColors.primary.withOpacity(0.2);
              } else {
                return Colors.transparent;
              }
            },
          ),
          confirmButtonStyle: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith<Color?>(backGroundTextButton),
            textStyle: WidgetStateProperty.resolveWith(
              (Set<WidgetState> states) {
                if (states.contains(WidgetState.focused)) return AppTextStyles.themeBodyMedium.copyWith(fontSize: state.scaleText! * 12);
                return AppTextStyles.themeBodyMedium.copyWith(fontSize: state.scaleText! * 12);
              },
            ),
          ),
          rangePickerBackgroundColor: AppColors.primary,
          yearBackgroundColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.selected)) {
                return AppColors.primary;
              } else if (states.contains(WidgetState.focused)) {
                return AppColors.primary.withOpacity(0.2);
              } else {
                return Colors.transparent;
              }
            },
          ),
          yearOverlayColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.selected)) {
                return AppColors.primary;
              } else if (states.contains(WidgetState.focused)) {
                return AppColors.primary.withOpacity(0.2);
              } else {
                return Colors.transparent;
              }
            },
          ),
          todayBackgroundColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.selected)) {
                return AppColors.primary;
              } else if (states.contains(WidgetState.focused)) {
                return AppColors.primary.withOpacity(0.2);
              } else {
                return Colors.white;
              }
            },
          ),
          todayForegroundColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.selected)) {
                return AppColors.blue;
              } else if (states.contains(WidgetState.focused)) {
                return AppColors.blue;
              } else {
                return Colors.blue;
              }
            },
          ),
          todayBorder: const BorderSide(
            color: AppColors.primary,
            width: 1,
          ),
          dividerColor: AppColors.lightGrey,
          weekdayStyle: WidgetStateTextStyle.resolveWith(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.focused)) return AppTextStyles.themeBodyMedium.copyWith(fontSize: state.scaleText! * 28);
              return AppTextStyles.themeBodyMedium.copyWith(fontSize: state.scaleText! * 28, color: Colors.red);
            },
          ),
        ),
        snackBarTheme: const SnackBarThemeData(
          actionBackgroundColor: Colors.red,
          backgroundColor: Colors.white,
          actionTextColor: Colors.black,
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.lightGrey,
          thickness: 1.0,
          indent: 16.0,
          endIndent: 16.0,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: AppColors.primaryText,
          foregroundColor: AppColors.white,
          elevation: 4.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          refreshBackgroundColor: Colors.red,
          circularTrackColor: AppColors.lightGrey,
          linearTrackColor: AppColors.lightGrey,
          color: AppColors.primaryText,
          linearMinHeight: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: AppTextStyles.themeLabelLarge.copyWith(
            color: AppColors.primary,
          ),
          hintStyle: AppTextStyles.themeTitleMedium.copyWith(color: Colors.grey, fontSize: 16),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.grey),
          ),
          isCollapsed: true,
          alignLabelWithHint: true,
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.green[300]!),
          ),
          fillColor: Colors.red,
          focusColor: Colors.red,
          helperStyle: AppTextStyles.themeLabelLarge.copyWith(
            color: Colors.red,
          ),
          helperMaxLines: 100,
          prefixIconColor: AppColors.primary,
          suffixIconColor: AppColors.primary,
        ),
        drawerTheme: DrawerThemeData(
          backgroundColor: AppColors.backgroundGrey,
          surfaceTintColor: const Color(0xFF6750A4),
          width: context.mediaQuery.size.width * 0.7,
        ),
        searchViewTheme: const SearchViewThemeData(
          backgroundColor: Colors.white,
          dividerColor: Colors.grey,
          constraints: BoxConstraints(minHeight: 60),
        ),
        cardTheme: CardTheme(
          color: AppColors.white,
          shadowColor: AppColors.grey,
          elevation: 1,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        pageTransitionsTheme: PageTransitionsTheme(
          builders: const {
            TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
          },
        ),
        popupMenuTheme: const PopupMenuThemeData(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
      );
}
