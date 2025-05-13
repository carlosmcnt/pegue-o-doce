import 'package:flutter/material.dart';
import 'package:pegue_o_doce/pedido/views/carrinho_badge_page.dart';

class Cores {
  static const Color primaryLight = Color(0xFFE3242B);
  static const Color accentLight = Color(0xFFBC544B);
  static const Color backgroundLight = Color.fromARGB(255, 250, 250, 250);
  static const Color textPrimaryLight = Color(0xFF4E342E);
  static const Color textSecondaryLight = Color(0xFF7B5E57);
  static const Color shadowLight = Color.fromARGB(255, 198, 74, 74);
  static const Color inputBackgroundLight = Colors.white;

  static const Color primaryDark = Colors.blueGrey;
  static const Color accentDark = Colors.blueGrey;
  static const Color backgroundDark = Color(0xFF212121);
  static const Color textPrimaryDark = Colors.white;
  static const Color textSecondaryDark = Color(0xFFBDBDBD);
  static const Color shadowDark = Colors.blueGrey;
  static const Color inputBackgroundDark = Color(0xFF424242);
}

class Tema {
  static ThemeData lightTheme = _buildTheme(
    primaryColor: Cores.primaryLight,
    accentColor: Cores.accentLight,
    backgroundColor: Cores.backgroundLight,
    textPrimaryColor: Cores.textPrimaryLight,
    textSecondaryColor: Cores.textSecondaryLight,
    shadowColor: Cores.shadowLight,
    inputBackgroundColor: Cores.inputBackgroundLight,
  );

  static ThemeData darkTheme = _buildTheme(
    primaryColor: Cores.primaryDark,
    accentColor: Cores.accentDark,
    backgroundColor: Cores.backgroundDark,
    textPrimaryColor: Cores.textPrimaryDark,
    textSecondaryColor: Cores.textSecondaryDark,
    shadowColor: Cores.shadowDark,
    inputBackgroundColor: Cores.inputBackgroundDark,
  );

  static ThemeData _buildTheme({
    required Color primaryColor,
    required Color accentColor,
    required Color backgroundColor,
    required Color textPrimaryColor,
    required Color textSecondaryColor,
    required Color shadowColor,
    required Color inputBackgroundColor,
  }) {
    return ThemeData(
      brightness: primaryColor == Cores.primaryDark
          ? Brightness.dark
          : Brightness.light,
      primaryColor: primaryColor,
      hintColor: accentColor,
      scaffoldBackgroundColor: backgroundColor,
      textTheme: TextTheme(
        labelSmall: TextStyle(color: textPrimaryColor),
        labelMedium: TextStyle(color: textPrimaryColor),
        bodyLarge: TextStyle(color: textPrimaryColor),
        bodyMedium: TextStyle(color: textPrimaryColor),
        labelLarge:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      listTileTheme: ListTileThemeData(
        tileColor: backgroundColor,
        iconColor: primaryColor,
        textColor: textPrimaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      tooltipTheme: const TooltipThemeData(
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        textStyle: TextStyle(color: Colors.white),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: backgroundColor,
        titleTextStyle: TextStyle(
          color: textPrimaryColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        contentTextStyle: TextStyle(
          color: textPrimaryColor,
          fontSize: 16,
        ),
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: backgroundColor,
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: accentColor,
        textTheme: ButtonTextTheme.primary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          textStyle: WidgetStateProperty.all(
            TextStyle(
              color: primaryColor,
              fontSize: 16,
            ),
          ),
          backgroundColor: WidgetStateProperty.all(accentColor),
          foregroundColor: WidgetStateProperty.all(backgroundColor),
          iconColor: WidgetStateProperty.all(backgroundColor),
        ),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: accentColor,
        selectionColor: accentColor.withValues(),
        selectionHandleColor: accentColor,
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.all(accentColor),
          textStyle: WidgetStateProperty.all(
            const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputBackgroundColor,
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: accentColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: textSecondaryColor),
        ),
        hintStyle: TextStyle(color: textSecondaryColor),
        labelStyle: TextStyle(color: textPrimaryColor),
        prefixStyle: TextStyle(color: textPrimaryColor),
        prefixIconColor: accentColor,
        suffixIconColor: accentColor,
        disabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: textSecondaryColor),
        ),
      ),
      cardTheme: CardTheme(
        color: backgroundColor,
        elevation: 4,
        shadowColor: shadowColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(
            width: 1,
            style: BorderStyle.solid,
            color: Colors.grey,
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Colors.grey,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: backgroundColor,
        selectedColor: accentColor,
        secondarySelectedColor: accentColor,
        disabledColor: textSecondaryColor,
        labelStyle: TextStyle(
          color: textSecondaryColor,
          fontSize: 16,
        ),
        secondaryLabelStyle: TextStyle(
          color: textPrimaryColor,
          fontSize: 16,
        ),
      ),
      dataTableTheme: DataTableThemeData(
        dataTextStyle: TextStyle(
          color: textPrimaryColor,
          fontSize: 15,
        ),
        columnSpacing: 30,
        headingTextStyle: TextStyle(
          color: textPrimaryColor,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey,
            width: 1,
          ),
        ),
      ),
      iconTheme: IconThemeData(color: accentColor),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
      ),
      shadowColor: shadowColor,
    );
  }

  static AppBar menuPrincipal() {
    return AppBar(
      toolbarHeight: const Size.fromHeight(70).height,
      centerTitle: true,
      title: Image.asset(
        "assets/images/logo.png",
        fit: BoxFit.cover,
        height: 90,
      ),
      actions: const [
        CarrinhoBadgeWidget(),
      ],
    );
  }

  static AppBar padrao(String descricao) {
    return AppBar(
      toolbarHeight: const Size.fromHeight(70).height,
      centerTitle: true,
      title: Text(
        descricao,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: const [
        CarrinhoBadgeWidget(),
      ],
    );
  }

  static AppBar historicoPedido(String descricao, List<Widget> acoes) {
    return AppBar(
      toolbarHeight: const Size.fromHeight(70).height,
      centerTitle: true,
      title: Text(
        descricao,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        const CarrinhoBadgeWidget(),
        ...acoes,
      ],
    );
  }
}
