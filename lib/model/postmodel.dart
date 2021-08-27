class PostModel{
  
  int id;
int userid;
String title;
String body;
PostModel({this.id=0,this.userid=0,this.title="",this.body=""});
factory PostModel.fromMap({Map? map}){
  if(map==null)return PostModel();
  return PostModel(
    id: map["id"]??0,
    userid: map["user_id"]??0,
    title: map["title"]??"",
    body: map["body"]??""
  );
}
}