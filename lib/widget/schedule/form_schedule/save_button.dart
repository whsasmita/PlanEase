import 'package:flutter/material.dart';

class SaveButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;
  final String buttonText; // NEW: Add buttonText property

  const SaveButton({
    super.key,
    required this.onPressed,
    required this.isLoading,
    this.buttonText = 'Simpan', // NEW: Set a default value
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E8C7A),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                buttonText, // Use the new property
                style: const TextStyle(fontSize: 18),
              ),
      ),
    );
  }
}