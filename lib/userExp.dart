import 'package:flutter/material.dart';

class UserExperienceScreen extends StatefulWidget {
  const UserExperienceScreen({Key? key}) : super(key: key);

  @override
  State<UserExperienceScreen> createState() => _UserExperienceScreenState();
}

class _UserExperienceScreenState extends State<UserExperienceScreen> {
  int selectedRating = 0;
  final feedbackController = TextEditingController();

  void _submitFeedback() {
    if (selectedRating == 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please select a rating")));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Thank you for your feedback!")),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Rate Your Experience"),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "How was your experience?",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),

            /// ⭐ STAR RATING
            Row(
              children: List.generate(5, (index) {
                return IconButton(
                  onPressed: () {
                    setState(() {
                      selectedRating = index + 1;
                    });
                  },
                  icon: Icon(
                    index < selectedRating ? Icons.star : Icons.star_border,
                    color: Colors.red,
                    size: 32,
                  ),
                );
              }),
            ),

            const SizedBox(height: 20),

            /// ✍ FEEDBACK
            TextField(
              controller: feedbackController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: "Share your experience",
                border: OutlineInputBorder(),
              ),
            ),

            const Spacer(),

            /// ✅ SUBMIT
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _submitFeedback,
                child: const Text("Submit", style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    feedbackController.dispose();
    super.dispose();
  }
}
