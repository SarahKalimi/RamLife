/// This library handles storing all the data in the app. 
/// 
/// This library contains dataclasses to store and serialize data.
/// The dataclasses have logical properties and methods in order
/// to abstract business logic from the rest of the application.
/// 
/// In other words, any logic that separates this app from any 
/// other app should be implemented in this library.
library data;

export "src/data/admin.dart";
export "src/data/feedback.dart";
export "src/data/reminder.dart";
export "src/data/schedule.dart";
export "src/data/sports.dart";
export "src/data/student.dart";
export "src/data/times.dart";
