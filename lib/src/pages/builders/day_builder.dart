import "package:flutter/material.dart";

import "package:ramaz/data.dart";
import "package:ramaz/models.dart";
import "package:ramaz/widgets.dart";

import "special_builder.dart";

/// A widget to guide the admin in modifying a day in the calendar. 
/// 
/// Creates a popup that allows the admin to set the [Letters] and [Special]
/// for a given day in the calendar, even providing an option to create a custom
/// [Special].
class DayBuilder extends StatelessWidget {
	/// Returns the [Day] created by this widget. 
	static Future<Day> getDay({
		@required BuildContext context, 
		@required DateTime date
	}) => showDialog<Day>(
		context: context, 
		builder: (_) => DayBuilder(date: date),
	);

	/// The date to modify. 
	final DateTime date;

	/// Creates a widget to guide the user in creating a [Day] 
	const DayBuilder({
		@required this.date
	});

	@override
	Widget build (BuildContext context) => ModelListener<DayBuilderModel>(
		model: () => DayBuilderModel(Services.of(context).admin),
		// ignore: sort_child_properties_last
		child: FlatButton(
			onPressed: () => Navigator.of(context).pop(),
			child: const Text("Cancel"),
		),
		builder: (_, DayBuilderModel model, Widget cancel) => AlertDialog(
			title: const Text("Edit day"),
			content: Column (
				mainAxisSize: MainAxisSize.min,
				children: [
					Text("Date: ${date.month}/${date.day}"),
					const SizedBox(height: 20),
					Container(
						width: double.infinity,
						child: Wrap (
							alignment: WrapAlignment.spaceBetween,
							crossAxisAlignment: WrapCrossAlignment.center,
							children: [
								const Text("Select letter", textAlign: TextAlign.center),
								DropdownButton<Letters>(
									value: model.letter,
									hint: const Text("Letter"),
									onChanged: (Letters letter) => model.letter = letter,
									items: [
										for (final Letters letter in Letters.values)
											DropdownMenuItem<Letters>(
												value: letter,
												child: Text (lettersToString [letter]),
											)
									],
								)
							]
						),
					),
					const SizedBox(height: 20),
					Container(
						width: double.infinity,
						child: Wrap (
							runSpacing: 3,
							children: [
								const Text("Select schedule"),
								DropdownButton<Special>(
									value: model.special,
									hint: const Text("Schedule"),
									onChanged: (Special special) async {
										if (special.name == null && special.periods == null) {
											special = await SpecialBuilder.buildSpecial(context);
										}
										model.special = special;
									},
									items: [
										for (
											final Special special in 
											model.presetSpecials + model.userSpecials
										) DropdownMenuItem<Special>(
											value: special,
											child: Text(special.name),
										),
										DropdownMenuItem<Special>(
											value: const Special(null, null),
											child: SizedBox(
												child: Row(
													children: [
														const Text("Make new schedule"),
														Icon(Icons.add_circle_outline)
													]
												)
											)
										)
									],
								)
							]
						)
					)
				]
			),
			actions: [
				cancel,
				RaisedButton(
					onPressed: !model.ready ? null : () => 
						Navigator.of(context).pop(model.day),
					child: Text("Save", style: TextStyle(color: Colors.white)),
				)
			]
		),
	);
}
