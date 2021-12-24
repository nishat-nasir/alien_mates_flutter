class PostModelRes {
  String postId;
  String? imageUrl;
  int? numberOfLikes;
  int? numberOfJoins;
  String? title;
  String? description;
  bool isPost;
  bool isEvent;
  bool isNotice;
  String userId;
  int? joinLimit;

  PostModelRes(
      {required this.postId,
      this.imageUrl,
      this.numberOfLikes,
      this.numberOfJoins,
      this.description,
      this.title,
      this.joinLimit,
      required this.userId,
      required this.isEvent,
      required this.isNotice,
      required this.isPost});
}
