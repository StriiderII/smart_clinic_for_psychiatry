import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';
import 'package:smart_clinic_for_psychiatry/data/database/firebase/FireBaseUtils.dart';
import 'package:smart_clinic_for_psychiatry/data/datasourceContracts/AuthenticationDataSource.dart';
import 'package:smart_clinic_for_psychiatry/domain/model/userModel/UserModel.dart';

@Injectable(as: AuthenticationDataSource)
class AuthenticationOnlineDataSource extends AuthenticationDataSource {
  FirebaseUtils firebaseUtils;

  @factoryMethod
  AuthenticationOnlineDataSource(this.firebaseUtils);

  @override
  Future<MyUser?> register(String name, String email, String password,
      String passwordVerification, String phone, String role) async {
    try {
      // Check if passwords match
      if (password != passwordVerification) {
        throw Exception("Passwords do not match");
      }

      // Create user in Firebase Authentication
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // Create MyUser object with the provided information, including role
      MyUser myUser = MyUser(
          id: credential.user?.uid ?? '',
          name: name,
          email: email,
          phone: phone,
          role: role);

      // Save user data to Firestore using FirebaseUtils
      await FirebaseUtils.addUserToFireStore(myUser);

      return myUser; // Return the created user object
    } catch (e) {
      print("Error registering user: $e");
      return null;
    }
  }

  @override
  Future<MyUser?> login(String email, String password) async {
    try {
      // Sign in with email and password
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      // Retrieve user data from Firestore using FirebaseUtils
      var user =
          await FirebaseUtils.readUserFromFireStore(credential.user?.uid ?? '');

      // Check if user data is retrieved successfully
      if (user != null) {
        // Update the user object with the retrieved data, including the role
        user.role =
            user.role ?? ''; // Assign an empty string if role is not present
        return user;
      } else {
        return null; // Login failed if user data not retrieved
      }
    } catch (e) {
      print("Error logging in: $e");
      return null;
    }
  }

  @override
  Future<MyUser?> logout() async {
    try {
      await FirebaseAuth.instance.signOut(); // Sign out the user
    } catch (e) {
      print("Error logging out: $e");
    }
    return null;
  }

  @override
  Future<MyUser?> resetPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } catch (e) {
      print("Error resetting password: $e");
    }
    return null;
  }

  @override
  Future<MyUser?> updateUserInfo(String newName, String newPhone) async {
    try {
      // Get the current user
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("User not logged in");
      }

      // Create an update map with only the changed fields
      final updateMap = <String, String>{};
      if (newName.isNotEmpty) {
        updateMap['name'] = newName;
      }
      if (newPhone.isNotEmpty) {
        updateMap['phone'] = newPhone;
      }

      // Check if any update is needed
      if (updateMap.isEmpty) {
        // No changes, return the current user without update
        final retrievedUser = await FirebaseUtils.readUserFromFireStore(user.uid);
        return retrievedUser;
      }

      // Update user information in Firestore
      final docRef = FirebaseFirestore.instance
          .collection(MyUser.collectionName)
          .doc(user.uid);
      await docRef.update(updateMap);

      // Retrieve and return the updated user object
      final retrievedUser = await FirebaseUtils.readUserFromFireStore(user.uid);

      // Handle the case where retrievedUser is null
      if (retrievedUser == null) {
        // Implement your desired behavior (e.g., log an error, return null)
        print("Error retrieving updated user data");
        return null;
      } else {
        return retrievedUser;
      }
    } catch (e) {
      print("Error updating user info: $e");
      return null;
    }
  }


  @override
  Future<MyUser?> changePassword(String currentEmail, String currentPassword, String newPassword, String confirmPassword) async {
    try {
      // Check if newPassword matches confirmPassword
      if (newPassword != confirmPassword) {
        throw Exception("New password and confirm password do not match");
      }

      // Get the user object
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("User not logged in");
      }

      // Re-authenticate the user with their current email and password
      final credential = await EmailAuthProvider.credential(
          email: currentEmail, password: currentPassword);
      await user.reauthenticateWithCredential(credential);

      // Update the password on Firebase Authentication
      await user.updatePassword(newPassword);

      // Inform the user about successful password change

    } catch (e) {
      print("Error changing password: $e");
    }
  }




}

