 import 'package:flutter/material.dart';

Widget buildCommentItem(
      String username, String comment, BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.03),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: MediaQuery.of(context).size.width * 0.045,
            backgroundImage:
                NetworkImage(''),
          ),
          SizedBox(width: MediaQuery.of(context).size.width * 0.03),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.03),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    username,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: MediaQuery.of(context).size.width * 0.04,
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.005),
                  Text(
                    comment,
                    style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.035),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: MediaQuery.of(context).size.width * 0.02),
          IconButton(
            icon: Icon(
              Icons.favorite_border,
              size: MediaQuery.of(context).size.width * 0.05,
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }