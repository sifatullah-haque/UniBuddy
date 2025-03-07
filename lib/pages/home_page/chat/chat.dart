import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'chat_detail.dart'; // Add this import

class Chat extends StatefulWidget {
  const Chat({super.key});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildChatList('Friends'),
                _buildChatList('Faculty'),
                _buildChatList('Administration'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: Size.fromHeight(70.h),
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30.0),
            bottomRight: Radius.circular(30.0),
          ),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xff6686F6), Color(0xff60BBEF)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(width: 40.w),
                Text(
                  "Messages",
                  style: TextStyle(
                    fontSize: 25.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.search,
                    color: Colors.white,
                  ),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: const Color(0xff6686F6),
        unselectedLabelColor: Colors.grey,
        indicatorColor: const Color(0xff6686F6),
        tabs: const [
          Tab(text: 'Friends'),
          Tab(text: 'Faculty'),
          Tab(text: 'Admin'),
        ],
      ),
    );
  }

  Widget _buildChatList(String type) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      itemCount: 10,
      itemBuilder: (context, index) {
        return _buildChatTile(type, index);
      },
    );
  }

  Widget _buildChatTile(String type, int index) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatDetail(
                name: 'User $index',
                type: type,
              ),
            ),
          );
        },
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: const Color(0xff6686F6),
          child: Text(
            'U',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          'User $index',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16.sp,
          ),
        ),
        subtitle: Text(
          'Last message from user $index',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14.sp,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '12:30 PM',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12.sp,
              ),
            ),
            SizedBox(height: 5.h),
            Container(
              padding: EdgeInsets.all(6.w),
              decoration: const BoxDecoration(
                color: Color(0xff6686F6),
                shape: BoxShape.circle,
              ),
              child: Text(
                '2',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
