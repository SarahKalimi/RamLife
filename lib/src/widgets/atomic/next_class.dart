import "package:flutter/material.dart";

import "package:ramaz/constants.dart";
import "package:ramaz/data.dart";
import "package:ramaz/widgets.dart";

import "info_card.dart";
import "reminder_tile.dart";

/// A decorative border around a special addition to [NextClass]. 
class SpecialTile extends StatelessWidget {
	/// The widget to go inside the border. 
	final Widget child;

	/// Creates a decorative border. 
	const SpecialTile({this.child});

	@override
	Widget build (BuildContext context) => Padding (
		padding: const EdgeInsets.symmetric(horizontal: 10),
		child: Container (
			foregroundDecoration: ShapeDecoration(
				shape: RoundedRectangleBorder(
					side: BorderSide(color: Theme.of(context).primaryColor),
					borderRadius: BorderRadius.circular(20),
				)
			),
			child: child,
		)
	);
}

/// A widget to represent the next class. 
class NextClass extends StatelessWidget {
	/// Whether today has a modified schedule. 
	/// 
	/// This determines whether the times should be shown.
	final bool modified; 

	/// Whether this is the next period or not.
	/// 
	/// This changes the text from "Right now" to "Up next". 
	final bool next;

	/// The period to represent. 
	final Period period;

	/// The subject associated with [period]. 
	final Subject subject;

	/// The reminders that apply for this period. 
	/// 
	/// These are indices in the reminders data model.
	final List<int> reminders;

	/// Creates an info tile to represent a period. 
	const NextClass({
		@required this.period,
		@required this.subject,
		@required this.reminders,
		@required this.modified,
		this.next = false,
	});

	@override 
	Widget build (BuildContext context) => Column(
		children: [
			InfoCard(
				icon: next ? Icons.restore : Icons.school,
				children: modified 
					? const ["See side panel or click for schedule"] 
					: period?.getInfo(subject),
				page: Routes.schedule,
				title: modified ? "Times unavailable" : 
					period == null
						? "School is over"
						: "${next ? 'Right now' : 'Next'}: ${subject?.name ?? period.period}",
			),
			if (period?.activity != null) 
				SpecialTile(child: ActivityTile(period.activity)),
			for (final int index in reminders) 
				SpecialTile(child: ReminderTile(index: index))
		]
	);
}