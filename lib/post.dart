
class Post {

  final int userId;
  final int id;
  final String title;
  final String body;

	Post.fromJsonMap(Map<String, dynamic> map): 
		userId = map["userId"],
		id = map["id"],
		title = map["title"],
		body = map["body"];

	Map<String, dynamic> toJson() {
		final Map<String, dynamic> data = new Map<String, dynamic>();
		data['userId'] = userId;
		data['id'] = id;
		data['title'] = title;
		data['body'] = body;
		return data;
	}
}
