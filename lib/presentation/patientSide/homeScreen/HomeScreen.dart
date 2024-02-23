import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:smart_clinic_for_psychiatry/di/di.dart';
import 'package:smart_clinic_for_psychiatry/presentation/common/components/appTheme/my_theme.dart';
import 'package:smart_clinic_for_psychiatry/presentation/newsScreen/screens/NewsScreen.dart';
import 'package:smart_clinic_for_psychiatry/presentation/patientSide/assessmentScreen/AssessmentScreen.dart';
import 'package:smart_clinic_for_psychiatry/presentation/patientSide/chatScreen/ChatScreen.dart';
import 'package:smart_clinic_for_psychiatry/presentation/patientSide/homeScreen/HomeScreenViewModel.dart';
import 'package:smart_clinic_for_psychiatry/presentation/patientSide/servicesScreen/ServicesScreen.dart';
import 'package:smart_clinic_for_psychiatry/presentation/patientSide/settingsScreen/SettingsScreen.dart';


class HomeScreen extends StatefulWidget {
  static const String routeName = 'test screen';

  HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var viewModel = getIt<HomeViewModel>();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeViewModel, HomeScreenState>(
      bloc: viewModel,
      builder: (context, state) {
        int selectedIndex = 0;
        late Widget bodyWidget;

        switch (state.runtimeType) {
          case HomeScreenTabState:
            {
              selectedIndex = 0;
              bodyWidget = ServicesScreen();
            }
            break;
          case NewsScreenState:
            {
              selectedIndex = 1;
              bodyWidget = NewsScreen();
            }
            break;
          case ChatScreenState:
            {
              selectedIndex = 2;
              bodyWidget = ChatScreen();
            }
            break;
          case AssessmentScreenState:
            {
              selectedIndex = 3;
              bodyWidget = AssessmentScreen();
            }
            break;
          case SettingsScreenState:
            selectedIndex = 4;
            bodyWidget = SettingsScreen();
            break;
          default:
            throw Exception("Invalid state: $state");
        }

        return Scaffold(
          backgroundColor: MyTheme.whiteColor,
          bottomNavigationBar: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: GNav(
              backgroundColor: MyTheme.primaryLight,
              haptic: true,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 25),
              color: MyTheme.whiteColor,
              tabBorderRadius: 20,
              iconSize: 25,
              tabBackgroundColor: MyTheme.backgroundButtonColor,
              activeColor: MyTheme.primaryLight,
              gap: 10,
              onTabChange: (index) {
                viewModel.onTabClick(index);
              },
              tabs: [
                GButton(
                  icon: selectedIndex == 0 ? FontAwesomeIcons.house : FontAwesomeIcons.house,
                  text: 'Home',
                ),
                GButton(
                  icon: selectedIndex == 1 ? FontAwesomeIcons.newspaper : FontAwesomeIcons.newspaper,
                  text: 'Article',
                ),
                GButton(
                  icon: selectedIndex == 2 ? FontAwesomeIcons.rocketchat : FontAwesomeIcons.rocketchat,
                  text: 'Chat',
                ),
                GButton(
                  icon: selectedIndex == 3
                      ? FontAwesomeIcons.heart
                      : FontAwesomeIcons.heart,
                  text: 'Tests',
                ),
                GButton(
                  icon: selectedIndex == 4 ? Icons.settings : Icons.settings,
                  text: 'Settings',
                ),
              ],
            ),
          ),
          body: bodyWidget,
        );
      },
    );
  }
}
