import 'package:so_tay_mon_an/MenuController.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class Header extends StatelessWidget {
  const Header({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.menu),
          onPressed: context.read<MenuController>().controlMenu,
        ),
        Spacer(),
        SizedBox(
          width: 30,
        ),
        Text(
          "Trang Admin",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        Spacer(),
        ProfileCard()
      ],
    );
  }
}

class ProfileCard extends StatelessWidget {
  const ProfileCard({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 16),
      padding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16 / 2,
      ),
      child: Image.asset(
        "assets/images/profile_pic.png",
        height: 38,
      ),
    );
  }
}

class SearchField extends StatelessWidget {
  const SearchField({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: "Search",
        fillColor: const Color(0xFF2A2D3E),
        filled: true,
        border: const OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        suffixIcon: InkWell(
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.all(16 * 0.75),
            margin: const EdgeInsets.symmetric(horizontal: 16 / 2),
            decoration: const BoxDecoration(
              color: Color(0xFF2697FF),
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            child: SvgPicture.asset("assets/icons/Search.svg"),
          ),
        ),
      ),
    );
  }
}
