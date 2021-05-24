import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:githubprofilesapp/githubuser.dart';
import 'package:githubprofilesapp/repo.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<User> GithubUser;
  Future<List<Repo>> GithubRepo;

  @override
  Widget build(BuildContext context) {
    final searchController = TextEditingController();
    return MaterialApp(
      title: 'Welcome to Flutter',
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text('Github Profile Search App'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(18),
            child: Column(
              children: [
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                      hintText: 'Search Username', icon: Icon(Icons.search)),
                ),
                SizedBox(
                  height: 120,
                ),
                FutureBuilder(
                  future: GithubUser,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    if (snapshot.data == null) {
                      return Center(
                        child: Text('Find a user'),
                      );
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text("User not found"));
                    }

                    final user = snapshot.data;
                    return Column(
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(user.avatarUrl),
                          radius: 70,
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          user.login,
                          style: Theme.of(context).textTheme.headline5,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          user.location,
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                Text('Repositories'),
                                Text(user.publicRepos.toString()),
                              ],
                            ),
                            Column(
                              children: [
                                Text('Followers'),
                                Text(user.followers.toString()),
                              ],
                            ),
                            Column(
                              children: [
                                Text('Following'),
                                Text(user.following.toString()),
                              ],
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  height: 200,
                  child: FutureBuilder(
                      future: GithubRepo,
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (snapshot.data == null) {
                          return Center(
                            child: Text(searchController.text.toString()),
                          );
                        }
                        if (snapshot.hasError) {
                          return Center(child: Text("User not found"));
                        }

                        return ListView.builder(
                            itemCount: snapshot.data.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Padding(
                                padding: EdgeInsets.only(bottom: 5),
                                child: ListTile(
                                  tileColor: Colors.lightBlue,
                                  onTap: () {},
                                  title: Text(
                                    snapshot.data[index].fullName,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              );
                            });
                      }),
                )
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              GithubRepo = fetchRepo(searchController.text);
              GithubUser = fetchGithubUser(searchController.text);
            });
          },
          child: Icon(Icons.search),
        ),
      ),
    );
  }
}

Future<User> fetchGithubUser(String user) async {
  final response =
      await http.get(Uri.parse('https://api.github.com/users/$user'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return User.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
}

List<Repo> parseRepo(String responseBody) {
  var list = json.decode(responseBody) as List<dynamic>;
  List<Repo> repos = list.map((model) => Repo.fromJson(model)).toList();
  return repos;
}

Future<List<Repo>> fetchRepo(String user) async {
  final response =
      await http.get(Uri.parse("https://api.github.com/users/$user/repos"));
  if (response.statusCode == 200) {
    return compute(parseRepo, response.body);
  } else {
    throw Exception('Request API error');
  }
}
