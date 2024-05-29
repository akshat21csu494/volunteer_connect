import 'package:flutter/material.dart';

import '../../components/homeDrawer.dart';

class TermsCondition extends StatelessWidget {
  const TermsCondition({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.primary,
        centerTitle: true,
        title: Text('Terms & Conditions', style: TextStyle(color: theme.onPrimary)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: const HomeDrawer(),
      body: const SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            children: [
              SelectableText('Welcome to SevaSanskriti!',style :TextStyle(fontSize: 24,fontWeight: FontWeight.w700)),
              SizedBox(height: 12),
              SelectableText('These terms and conditions outline the rules and regulations for the , use of SevaSanskriti\'s App, located at '
                  'This website and our app.',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12),
              SelectableText('By accessing this App, we assume you accept these terms and conditions. Do not continue to use SevaSanskriti '
                  'if you do not agree toall of the terms and conditions stated on this page. Welcome toSevaSanskriti! These terms and '
                  'conditions outline the rules andregulations for the use of SevaSanskriti\'s App. By accessing thisApp, we assume you '
                  'accept these terms and conditions. Do not continue to use SevaSanskriti if you do not agree to all of the terms and '
                  'conditions stated on this page.',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12),
              SelectableText("SevaSanskriti is a platform designed to connect NGOs and individuals willing to volunteer or contribute "
                  "donations. By using this platform, you agree to comply with and be bound by the following terms and conditions of use.",
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),


              SelectableText("Donations and Volunteering!",style :TextStyle(fontSize: 22,fontWeight: FontWeight.w600)),
              SizedBox(height: 8),
              UnorderedList(text: "SevaSanskriti provides a platform for NGOs to list their causes and projects seeking donations or "
                  "volunteers. Users willing to contribute or volunteer can access these listings and engage with the NGOs directly "
                  "through our platform."),
              SizedBox(height: 8),
              UnorderedList(text: "SevaSanskriti does not directly handle or process any donations. All transactions, contributions, or "
                  "volunteering commitments occur directly between the users and the respective NGOs. We do not take responsibility for "
                  "the use or misuse of donations made through our platform."),
              SizedBox(height: 16),


              SelectableText('User Conduct!',style :TextStyle(fontSize: 22,fontWeight: FontWeight.w600)),
              SizedBox(height: 8),
              UnorderedList(text: "Users must provide accurate and truthful information when "
                  "registering or engaging with NGOs on SevaSanskriti."),
              SizedBox(height: 8),
              UnorderedList(text: "Users agree to use the platform responsibly and not engage in any activities that could harm or "
                  "disrupt the website's functionality or the experience of other users."),
              SizedBox(height: 8),
              UnorderedList(text: "Users are responsible for their interactions and transactions with NGOs. SevaSanskriti is not liable "
                  "for any disputes, issues, or damages arising from these interactions."),
              SizedBox(height: 8),
              UnorderedList(text: "The content, logos, design, and materials on SevaSanskriti are protected by intellectual property laws. "
                  "Users agree not to reproduce, distribute, or modify any content from SevaSanskriti without prior written permission."),
              SizedBox(height: 8),
              UnorderedList(text: "SevaSanskriti values user privacy. Our Privacy Policy outlines how we collect, use, and protect user "
                  "information. By using our platform, you consent to the practices outlined in the Privacy Policy."),
              SizedBox(height: 8),
              UnorderedList(text: "SevaSanskriti strives to maintain the accuracy and reliability of the information provided on the "
                  "platform. However, we do not guarantee the completeness, accuracy, or reliability of any content or information."),
              SizedBox(height: 8),
              UnorderedList(text: "We are not liable for any direct, indirect, incidental, consequential, or punishing damages arising "
                  "from the use or inability to use our platform or any transactions conducted through it."),
              SizedBox(height: 16),


              SelectableText('Changes of Terms and Conditions',
                  style :TextStyle(fontSize: 22,fontWeight: FontWeight.w600),textAlign: TextAlign.center),
              SizedBox(height: 8),
              UnorderedList(text: "SevaSanskriti reserves the right to modify or replace these terms and conditions at any time. Users "
                  "will be notified of any changes through the website. Continued use of the platform after modifications constitutes "
                  "acceptance of the new terms."),
              SizedBox(height: 16),


              SelectableText('Contact Information', style :TextStyle(fontSize: 22,fontWeight: FontWeight.w600)),
              SizedBox(height: 8),
              UnorderedList(text: "If you have any questions or concerns about these terms and conditions, please contact us at "
                  "sevasanskriti@gmail.com"),
              SizedBox(height: 8),
              UnorderedList(text: "By using SevaSanskriti, you agree to abide by these terms and conditions."),
            ],
          ),
        ),
      ),
    );
  }
}

class UnorderedList extends StatelessWidget {
  final String text;
  final TextStyle? textStyle;

  const UnorderedList({
    super.key,
    required this.text,
    this.textStyle = const TextStyle(fontSize: 16)
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical:4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SelectableText("● ", style:textStyle),
          Expanded(child: SelectableText(text, style: textStyle,textAlign: TextAlign.justify,))
        ],
      ),
    );
  }
}
