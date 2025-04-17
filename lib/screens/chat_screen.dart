import 'package:chatnow/services/chat/chat_service.dart';
import 'package:chatnow/widgets/custom_chat_bubble.dart';
import 'package:chatnow/widgets/custom_textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String receiverID;
  final String receiverEmail;
  const ChatScreen({
    super.key,
    required this.receiverID,
    required this.receiverEmail,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController messageController = TextEditingController();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final ChatService chatService = ChatService();
  final ScrollController scrollController = ScrollController();
  final FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    // Add listener for keyboard appearance
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        _scrollToBottomWithDelay();
      }
    });

    // Initial scroll after widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottomWithDelay();
    });
  }

  // Safe scrolling method with delay and attachment check
  void _scrollToBottomWithDelay() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void sendMessage() async {
    if (messageController.text.isNotEmpty) {
      await chatService.sendMessage(
        messageController.text,
        widget.receiverID,
      );
      messageController.clear();
      _scrollToBottomWithDelay();
    }
  }

  @override
  void dispose() {
    messageController.dispose();
    scrollController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey,
        title: Text(widget.receiverEmail),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: chatService.getMessage(
                firebaseAuth.currentUser!.uid,
                widget.receiverID,
              ),
              builder: (context, AsyncSnapshot snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.grey),
                  );
                }
                if (!snapshot.hasData || snapshot.data == null) {
                  return const Center(child: Text("No messages yet"));
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  controller: scrollController,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 5,
                      ),
                      child: Align(
                        alignment:
                            message['senderID'] == firebaseAuth.currentUser!.uid
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                        child: CustomChatBubble(
                          msg: message['message'],
                          color: message['senderID'] ==
                                  firebaseAuth.currentUser!.uid
                              ? Colors.green
                              : Colors.grey.shade400,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
            child: Row(
              children: [
                Expanded(
                  child: CustomTextfield(
                    focusNode: focusNode,
                    controller: messageController,
                    hintText: 'Enter message',
                  ),
                ),
                const SizedBox(width: 15),
                GestureDetector(
                  onTap: sendMessage,
                  child: const CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.green,
                    child: Icon(Icons.arrow_upward, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
