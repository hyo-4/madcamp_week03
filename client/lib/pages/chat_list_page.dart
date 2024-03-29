import 'dart:convert';

import 'package:client/pages/chatpage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ChatList extends StatefulWidget {
  const ChatList({super.key});

  @override
  State<ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  String userId = "";
  List<Map<String, dynamic>> chatList = [];

  @override
  void initState() {
    super.initState();
    // loadUserId();
    getlist();
  }

  Future<void> loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('user_id') ?? 'qq';
    });
    print(userId);
  }

  Future<void> getlist() async {
    String url = 'http://172.10.7.78/get_chat_list';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('user_id') ?? 'qq';
    });
    final Map<String, dynamic> data = {
      'myid': userId, //아거 userid로 고쳐야함
    };
    print('Sending data: $data');
    try {
      final response = await http.post(
        Uri.parse(url),
        body: jsonEncode(data),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          chatList = List<Map<String, dynamic>>.from(data['chat_list']);
          print(chatList);
        });
      } else {
        throw Exception('Failed to load chat list');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat List'),
      ),
      body: ListView.builder(
        itemCount: chatList.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatPage(
                    bookIndex: chatList[index]['bookid'],
                    yourId: chatList[index]['yourid'],
                  ),
                ),
              );
            },
            child: Container(
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 3,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Book Image
                  Container(
                    width: 80,
                    height: 120,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(chatList[index]['book_row'][0][8]), // Book Image URL
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Conversation Partner ID
                        Text(
                          '상대방: ${chatList[index]['yourid']}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        // Book Title
                        Text(
                          '책 제목: ${chatList[index]['book_row'][0][2]}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        // Author
                        Text('저자: ${chatList[index]['book_row'][0][3]}'),
                        // Publisher
                        Text('출판사: ${chatList[index]['book_row'][0][4]}'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),

    );
  }
}
