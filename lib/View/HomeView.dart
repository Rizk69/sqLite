import 'package:flutter/material.dart';
import 'package:sqlite/Helper/database_helper.dart';
import 'package:sqlite/model/UserModel.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  List<UserModel> userList = [];
  String? name, phone, email;
  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  bool flag = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Text('Contacts'),
      ),
      body: getAllUser(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  getAllUser() {
    return FutureBuilder(
        future: _getData(),
        builder: (context, snapshot) {
          return createListView(context, snapshot);
        });
  }

  Future<List<UserModel>> _getData() async {
    var dbHelper = DatabaseHelper.db;
    await dbHelper.getAllUsers().then((value) {
      userList = value;
    });
    return userList;
  }

  createListView(context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      // While the Future is still loading, show a loading indicator or placeholder.
      return const CircularProgressIndicator();
    } else if (snapshot.hasError) {
      // Handle any errors that occurred during fetching data.
      return Text('Error: ${snapshot.error}');
    } else if (snapshot.data == null) {
      // Handle the case where snapshot.data is null (no data available).
      return const Text('No data available.');
    } else {
      // Data has been successfully fetched and is not null.
      userList = snapshot.data;
      return ListView.builder(
        itemCount: userList.length,
        itemBuilder: (context, index) {
          // Build your list item here based on userList.
          return Dismissible(
              background: Container(
                color: Colors.red,
                child: const Padding(
                  padding: EdgeInsets.only(left: 50.0, top: 50),
                  child: Text(
                    'DELETE',
                    style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
                ),
              ),
              onDismissed: (direction) {
                DatabaseHelper.db.deleteUser(userList[index].id!);
              },
              key: UniqueKey(),
              child: _buildItem(userList[index], index));
        },
      );
    }
  }

  _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () => openAlertBox(null),
      backgroundColor: Colors.red,
      child: const Icon(Icons.add),
    );
  }

  openAlertBox(UserModel? userModel) {
    if (userModel != null) {
      name = userModel.name;
      phone = userModel.phone;
      email = userModel.email;
      flag = true;
    } else {
      name = '';
      phone = '';
      email = '';
      flag = false;
    }
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Container(
              margin: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
              ),
              height: MediaQuery.of(context).size.height / 3.8,
              width: MediaQuery.of(context).size.width / 5,
              child: Form(
                key: _key,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextFormField(
                      initialValue: name,
                      decoration: InputDecoration(
                          hintText: 'Add Name',
                          fillColor: Colors.grey[300],
                          border: InputBorder.none),
                      validator: (value) {
                        return null;
                      },
                      onSaved: (value) {
                        name = value;
                      },
                    ),
                    TextFormField(
                      initialValue: phone,
                      decoration: InputDecoration(
                          hintText: 'Add Phone',
                          fillColor: Colors.grey[300],
                          border: InputBorder.none),
                      validator: (value) {
                        return null;
                      },
                      onSaved: (value) {
                        phone = value;
                      },
                    ),
                    TextFormField(
                      initialValue: email,
                      decoration: InputDecoration(
                          hintText: 'Add Email',
                          fillColor: Colors.grey[300],
                          border: InputBorder.none),
                      validator: (value) {
                        return null;
                      },
                      onSaved: (value) {
                        email = value;
                      },
                    ),
                    TextButton(
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.red)),
                        onPressed: () {
                          flag ? editUser(userModel!.id!, context) : addUser();
                          Navigator.pop(context);
                        },
                        child: flag
                            ? const Text(
                                'Edit User',
                                style: TextStyle(color: Colors.white),
                              )
                            : const Text('Add User',
                                style: TextStyle(color: Colors.white)))
                  ],
                ),
              ),
            ),
          );
        });
  }

  void addUser() {
    _key.currentState?.save();
    var dbHelper = DatabaseHelper.db;
    dbHelper
        .insertUser(UserModel(email: email, name: name, phone: phone))
        .then((value) {});
  }

  void editUser(int id, context) {
    _key.currentState?.save();
    UserModel user = UserModel(id: id, name: name, phone: phone, email: email);
    var dbHelper = DatabaseHelper.db;
    dbHelper.updateUser(user).then((value) {
      Navigator.canPop(context);
      setState(() {
        flag = false;
      });
    });
  }

  _buildItem(UserModel userList, int index) {
    return Card(
      child: ListTile(
        title: Row(
          children: [
            Column(
              children: [
                CircleAvatar(
                  radius: 23,
                  backgroundColor: Colors.brown,
                  child: Center(
                    child: Text(
                      userList.name!.substring(0, 1).toLowerCase(),
                      style: const TextStyle(fontSize: 32, color: Colors.white),
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(
              width: 25,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.account_circle,
                      color: Colors.black,
                    ),
                    const Padding(padding: EdgeInsets.only(right: 15)),
                    Text(
                      userList.name!,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                      ),
                      softWrap: true,
                      maxLines: 2,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.phone,
                      color: Colors.black,
                    ),
                    const Padding(padding: EdgeInsets.only(right: 15)),
                    Text(
                      userList.phone!,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                      ),
                      softWrap: true,
                      maxLines: 1,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.email,
                      color: Colors.black,
                    ),
                    const Padding(padding: EdgeInsets.only(right: 15)),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 2.9,
                      child: Text(
                        userList.email!,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                        ),
                        softWrap: true,
                        maxLines: 1,
                        overflow: TextOverflow.clip,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        trailing: Padding(
          padding: const EdgeInsets.only(top: 25),
          child: IconButton(
            onPressed: () => _onEdit(userList, index),
            icon: const Icon(Icons.edit),
          ),
        ),
      ),
    );
  }

  _onEdit(UserModel userList, int index) {
    openAlertBox(userList);
  }
}
