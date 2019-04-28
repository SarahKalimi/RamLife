// VERIFY: onFieldSubmitted for password works when tapped off

import "package:flutter/material.dart";

import "home.dart";
import "../mock.dart";  // for logging in
import "../backend/firestore.dart" as Firestore;
import "../backend/auth.dart" as Auth;
import "../backend/student.dart";

class Login extends StatefulWidget {
	@override LoginState createState() => LoginState();
}

class LoginState extends State <Login> {
	static final RegExp usernameRegex = RegExp ("[a-z]+");
	static final RegExp passwordRegex = RegExp (r"([a-z]|\d)+");
	final FocusNode _passwordNode = FocusNode();
	final TextEditingController usernameController = TextEditingController();
	final TextEditingController passwordController = TextEditingController();
	final GlobalKey<ScaffoldState> key = GlobalKey();

	bool obscure = true;
	bool ready = false;
	// bool ready = false;
	Icon userSuffix;  // goes after the username prompt
	Student student;

	@override void dispose() {
		super.dispose();
		_passwordNode.dispose();
	}

	@override
	Widget build (BuildContext context) => Scaffold(
		key: key,
		appBar: AppBar (title: Text ("Login")),
		floatingActionButton: FloatingActionButton.extended (
			onPressed: ready ? login : null,
			icon: Icon (Icons.done),
			label: Text ("Submit"),
			backgroundColor: ready ? Colors.blue : Colors.grey
		),
		body: Padding (
			padding: EdgeInsets.all (20),
			child: SingleChildScrollView (
				child: Column (
					children: [
						Stack (children: [
							SizedBox (
								child: Center (child: CircularProgressIndicator()),
								height: 300,
								width: 300
							),
							Image.asset ("lib/logo.jpg"),
						]),
						Form (
							autovalidate: true,
							child: Column (
								children: [
									TextFormField (
										keyboardType: TextInputType.text,
										textInputAction: TextInputAction.next,
										onFieldSubmitted: transition,
										validator: usernameValidate,
										controller: usernameController,
										decoration: InputDecoration (
											icon: Icon (Icons.account_circle),
											labelText: "Username",
											helperText: "Enter your Ramaz username",
											suffix: userSuffix
										)
									),
									TextFormField (
										textInputAction: TextInputAction.done,
										focusNode: _passwordNode,
										controller: passwordController,
										validator: passwordValidator,
										obscureText: obscure,
										onFieldSubmitted: getStudentData,
										decoration: InputDecoration (
											icon: Icon (Icons.security),
											labelText: "Password",
											helperText: "Enter your Ramaz password",
											suffixIcon: IconButton (
												icon: Icon (obscure 
													? Icons.visibility 
													: Icons.visibility_off
												),
												onPressed: () => setState (() {obscure = !obscure;})
											)
										)
									)
								]
							)
						),
						SizedBox (height: 30),  // FAB covers textbox when keyboard is up
					]
				)
			)
		)
	);

	static bool capturesAll (String text, RegExp regex) => 
		text.isEmpty || regex.matchAsPrefix(text)?.end == text.length;

	String passwordValidator (String pass) => capturesAll (pass, passwordRegex)
		? null
		: "Only lower case letters and numbers";

	String usernameValidate(String text) => capturesAll (text, usernameRegex)
		? null
		: "Only lower case letters allowed";

	void login ([_]) async {
		final String username = usernameController.text;
		final String password = passwordController.text;
		await Auth.signin(username, password);
		final Map<String, dynamic> data = (await Firestore.getStudent(username)).data;
		Student student = Student.fromData(data);
		Navigator.of(context).pushReplacement(
			MaterialPageRoute (
				builder: (_) => HomePage (student)
			)
		);
	}

	void verify([_]) => setState(
		() => ready = (
			verifyUsername (usernameController.text) && 
			verifyPassword (student, passwordController.text)
		)
	);

	void transition ([String username]) => FocusScope.of(context)
		.requestFocus(_passwordNode);

}
