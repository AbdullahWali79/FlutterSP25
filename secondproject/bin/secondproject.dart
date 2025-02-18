import 'dart:io';

// Function to calculate simple interest
double calculateSimpleInterest(double principal, double rate, double time) {
  return (principal * rate * time) / 100;
}

void main() {
  // Taking user input
  stdout.write("Enter Principal Amount: ");
  double principal = double.parse(stdin.readLineSync()!);

  stdout.write("Enter Rate of Interest (%): ");
  double rate = double.parse(stdin.readLineSync()!);

  stdout.write("Enter Time (in years): ");
  double time = double.parse(stdin.readLineSync()!);

  // Calculate interest
  double interest = calculateSimpleInterest(principal, rate, time);

  // Display result
  print("\nSimple Interest: \$${interest.toStringAsFixed(2)}");
}
