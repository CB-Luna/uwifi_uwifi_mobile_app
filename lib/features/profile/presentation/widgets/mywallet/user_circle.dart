import 'package:flutter/material.dart';

import '../../../domain/entities/affiliated_user.dart';
import 'affiliated_user_detail.dart';

class UserCircle extends StatelessWidget {
  final String initials;
  final Color? color;
  final AffiliatedUser? user;

  const UserCircle({required this.initials, super.key, this.color, this.user});

  factory UserCircle.fromAffiliatedUser(AffiliatedUser user) {
    return UserCircle(
      initials: user.initials,
      // Use gray for affiliated users, green for non-affiliated
      color: user.isAffiliate ? Colors.grey.shade400 : Colors.green,
      user: user,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: user?.customerName ?? 'Usuario',
      child: GestureDetector(
        onTap: user != null
            ? () {
                showDialog(
                  context: context,
                  builder: (context) => AffiliatedUserDetail(user: user!),
                );
              }
            : null,
        child: Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: CircleAvatar(
            radius: 22,
            backgroundColor: color ?? Colors.grey.shade300,
            child: Text(
              initials,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
