import 'package:flutter/material.dart';

mixin InfiniteScrollMixin<T extends StatefulWidget> on State<T> {
  final ScrollController scrollController = ScrollController();
  final double _scrollThreshold = 200.0;

  @override
  void initState() {
    super.initState();
    scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    scrollController.removeListener(_handleScroll);
    scrollController.dispose();
    super.dispose();
  }

  //스크롤이 리스트의 끝에 닿으면 onScroll메서드를 추가합니다
  void _handleScroll() {
    if (scrollController.position.maxScrollExtent - scrollController.position.pixels <= _scrollThreshold) {
      onScroll();
    }
  }

  void onScroll();
//개발 가이드 내용: 3. 채팅방 목록뷰 위젯에 생성한 mixin을 활용하고,
// onScroll()를 overriding하여 목록을 추가로드할 수 있도록 합니다.
// 목록 추가로드는 페이징 혹은 커서링 방식으로 구현합니다.
}
