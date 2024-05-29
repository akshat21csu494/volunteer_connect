import 'package:flutter/material.dart';

import '../../components/alerts.dart';
import '../../components/buttonFill.dart';
import 'registerNGOLast.dart';

class Category extends StatefulWidget {

  final String name;
  final String year;
  final String location;
  final String volunteers;
  final String founders;
  final String email;

  const Category({
    super.key,
    required this.name,
    required this.year,
    required this.location,
    required this.volunteers,
    required this.founders,
    required this.email
  });

  @override
  State<Category> createState() => _CategoryState();
}

class _CategoryState extends State<Category> {

  List chipList = [
    "Health & Healthcare",
    "Environment & Conservation",
    "Children & Youth",
    "Poverty Alleviation",
    "Food Distribution",
    "Drug Abuse & Addiction",
    "Global Development",
    "Orphanage",
    "Democracy & Governance",
    "Mental Health Counseling",
    "Animal Welfare",
    "Old Age Home",
    "Bird Welfare",
    "Economic Development",
    "Other"
  ];

  List isSelected = [false, false, false, false, false, false, false, false,false, false, false, false, false, false, false, false];

  String? category;

  Alerts alerts = Alerts();

  void onNext(){
    if(category == null){
      alerts.SimpleAlert(context, 'Please Select the Category');
    } else {
      Navigator.of(context).push(MaterialPageRoute(builder: (context)=>RegisterNGOLast(
          name: widget.name,
          year: widget.year,
          location: widget.location,
          volunteers: widget.volunteers,
          founders: widget.founders,
          email: widget.email,
          category: category!
      )));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.background.withOpacity(0.0),
        scrolledUnderElevation: 0,
        elevation: 0,

        /// Back button
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            /// Title
            Text('Choose your Category',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: theme.primary),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 4),
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: theme.background,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: theme.primary.withOpacity(0.3),
                    blurStyle: BlurStyle.outer,
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Wrap(
                spacing: 4,
                runSpacing: -8,
                children: List.generate(
                  chipList.length,
                  (index) => ChoiceChip(
                    labelStyle: TextStyle(color: isSelected[index]? Colors.white : Colors.black),
                    padding: const EdgeInsets.all(4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                    side: BorderSide(color: theme.primary),
                    checkmarkColor: theme.primaryContainer,
                    selectedColor: theme.primary,
                    label: Text(chipList[index]),
                    selected: isSelected[index],
                    onSelected: (bool selected) {
                      setState(() {
                        for (int i = 0; i < isSelected.length; i++) {
                          if (i == index) {
                            isSelected[i] = selected;
                            if (selected) {
                              category = chipList[i];
                            }
                          } else {
                            isSelected[i] = false;
                          }
                        }
                      });
                    }
                  ),
                ),
              ),
            ),
            const Spacer(),

            /// Button
            ButtonFill(text: 'Next', onTap: onNext,),
          ],
        ),
      ),
    );
  }
}
