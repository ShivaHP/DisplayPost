import 'dart:convert';

import 'package:display_post/model/postmodel.dart';
import 'package:display_post/services/endpoint.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class PostList extends StatefulWidget {
  PostList({Key? key}) : super(key: key);

  @override
  _PostListState createState() => _PostListState();
}

class _PostListState extends State<PostList> {
  List<PostModel> postlist = [];
  List<PostModel> helperlist = [];
  int pagecounter = 0;
  bool showprogress = false;
  ScrollController scrollController = ScrollController();
  bool showsearchbar = false;
  TextEditingController textEditingController = TextEditingController();
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    scrollController.dispose();
    textEditingController.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchpostlist();

    scrollController.addListener(() {
      if (scrollController.hasClients) {
        if (scrollController.position.pixels ==
            scrollController.position.maxScrollExtent) {
          fetchpostlist();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // floatingActionButton: FloatingActionButton(
      //   child: Icon(Icons.add),
      //   onPressed: (){
      //     fetchpostlist();
      //   },
      // ),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          "Display Posts",
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
              letterSpacing: 0.5,
              color: Colors.black),
        ),
        actions: [
          IconButton(
              onPressed: () {
                showsearchbar = !showsearchbar;
                setState(() {});
              },
              icon: Icon(
                Icons.search,
                color: Colors.black,
              ))
        ],
      ),
      body: Container(
        child: Column(
          children: [
            AnimatedContainer(
              //  padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
              duration: Duration(milliseconds: 600),
              height: showsearchbar ? 100 : 0,
              width: double.infinity,
              child: TextFormField(
                  controller: textEditingController,
                  decoration: InputDecoration(
                      suffixIcon: IconButton(
                          onPressed: () {
                            textEditingController.clear();
                            postlist = helperlist;
                            setState(() {});
                          },
                          icon: Icon(
                            Icons.cancel,
                            color: showsearchbar
                                ? Colors.black
                                : Colors.transparent,
                          )),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                          enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                          focusedBorder:  OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      hintText: "Search by title"),
                  onChanged: (String text) {
                    postlist = helperlist.where((element) {
                      return element.title
                          .toLowerCase()
                          .contains(text.toLowerCase());
                    }).toList();
                    setState(() {});
                  }),
            ),
            Expanded(
              child: ListView.builder(
                  shrinkWrap: true,
                  physics: BouncingScrollPhysics(),
                  controller: scrollController,
                  itemCount: postlist.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      tileColor: index.isEven ? Colors.orange : Colors.white,
                      minVerticalPadding: 10,
                      leading: Text(
                        "${postlist[index].userid}",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 10),
                      ),
                      title: Text(
                        postlist[index].title,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          postlist[index].body,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              letterSpacing: 0.7),
                        ),
                      ),
                    );
                  }),
            ),
            Visibility(
              visible: showprogress,
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(),
              ),
            )
          ],
        ),
      ),
    );
  }

  fetchpostlist() async {
    setState(() {
      showprogress = true;
    });
    List data = [];
    Map body = {};
    pagecounter++;
    print("counter:$pagecounter");
    try {
      Response response =
          await get(Uri.parse(getposturl(pagenumber: pagecounter)));
      if (response.statusCode == 200) {
        //print(jsonDecode(response.body));
        body = jsonDecode(response.body);
        data = body["data"];
        data.forEach((element) {
          postlist.add(PostModel.fromMap(map: element));
        });
        helperlist = postlist;
        setState(() {
          showprogress = false;
        });
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Some Error Occurred")));
        setState(() {
          showprogress = false;
        });
      }
    } catch (errro) {
      print("error:$errro");
    }
  }
}
