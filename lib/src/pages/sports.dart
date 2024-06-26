import "package:flutter/material.dart";

import "package:ramaz/data.dart";
import "package:ramaz/models.dart";
import "package:ramaz/pages.dart";
import "package:ramaz/widgets.dart";

/// A Swipe to Refresh list of [SportsGame]s. 
/// 
/// This is used to simplify the logic between games that are sorted 
/// chronologically and by sport, since both will be split by past and 
/// future games. 
class GenericSportsView<T> extends StatelessWidget {
	/// A list of upcoming games. 
	/// 
	/// This can be any type as long as it can be used in [builder] to build 
	/// [SportsTile]s. 
	final List<T> upcoming;

	/// A list of past games. 
	/// 
	/// This can be any type as long as it can be used in [builder] to build 
	/// [SportsTile]s. 
	final List<T> recents;

	/// Builds a list of [SportsTile]s using [upcoming] and [recents]. 
	final Widget Function(T) builder;

	/// Defines the sports view model.
	final SportsModel model;

	/// Creates a list of [SportsTile]s. 
	const GenericSportsView({
		required this.upcoming,
		required this.recents,
		required this.builder,
		required this.model,
	});

	@override
	Widget build(BuildContext context) => TabBarView(
		children: [
			for (final List<T> gamesList in [upcoming, recents])
				RefreshIndicator(
					onRefresh: () async {
						model.loading = true;
						await model.refresh();
						model.loading = false;
					},
					child: ListView(
						padding: const EdgeInsets.symmetric(horizontal: 4),
						children: [
							if (model.loading) const LinearProgressIndicator(),
							for (final T game in gamesList) builder(game)
						]
					)
				)
		]
	);
}

/// Opens a menu with options for the selected game. 
/// 
/// This menu can only be accessed by administrators. 
void openMenu({
	required BuildContext context, 
	required int index, 
	required SportsModel model
}) => showDialog(
	context: context,
	builder: (BuildContext newContext) => SimpleDialog(
		title: Text(model.data.games [index].description),
		children: [
			SimpleDialogOption(
				onPressed: () async {
					Navigator.of(newContext).pop();
					final Scores? scores = await SportsScoreUpdater.updateScores(
						context, model.data.games [index]
					);
					if (scores == null) {
						return;
					}
					model.loading = true;
					await Models.instance.sports.replace(
						index, 
						model.data.games [index].replaceScores(scores)
					);
					model.loading = false;
				},
				child: const Text("Edit scores", textScaleFactor: 1.2),
			),
			const SizedBox(height: 10),
			SimpleDialogOption(
				onPressed: () async {
					Navigator.of(newContext).pop();
					model.loading = true;
					await Models.instance.sports.replace(
						index, 
						model.data.games [index].replaceScores(null)
					);
					model.loading = false;
				},
				child: const Text("Remove scores", textScaleFactor: 1.2),
			),
			const SizedBox(height: 10),
			SimpleDialogOption(
				onPressed: () async {
					Navigator.of(newContext).pop();
					model.loading = true;
					await Models.instance.sports.replace(
						index, 
						await SportsBuilder.createGame(context, model.data.games [index])
					);
					model.loading = false;
				},
				child: const Text("Edit game", textScaleFactor: 1.2),
			),
			const SizedBox(height: 10),
			SimpleDialogOption(
				onPressed: () async {
					Navigator.of(newContext).pop();
					final bool? confirm = await showDialog(
						context: context,
						builder: (BuildContext context) => AlertDialog(
							title: const Text("Confirm"),
							content: const Text("Are you sure you want to delete this game?"),
							actions: [
								TextButton(
									onPressed: () => Navigator.of(context).pop(false),
									child: const Text("Cancel"),
								),
								ElevatedButton(
									onPressed: () => Navigator.of(context).pop(true),
									child: const Text("Confirm"),
								)
							]
						)
					);
					if (confirm ?? false) {
						model.loading = true;
						await Models.instance.sports.delete(index);
						await model.refresh();
						model.loading = false;
					}
				},
				child: const Text("Remove game", textScaleFactor: 1.2),
			),
		]
	)
);

/// A page to show recent and upcoming games to the user.
class SportsPage extends NavigationItem<SportsModel>{
	@override
	SportsModel get model => super.model!;

	/// Creates the schedule page.
	SportsPage() : super(
		label: "Sports",
		icon: const Icon(Icons.sports),
		model: SportsModel(Models.instance.sports),
		shouldDispose: true,
	);

	@override
	AppBar get appBar => AppBar(
		title: const Text("Sports"),
		bottom: const TabBar(
			tabs: [
				Tab(text: "Upcoming"),
				Tab(text: "Recent"),
			]
		),
		actions: [
			if (model.isAdmin) Builder(
				builder: (context) => IconButton(
					icon: const Icon(Icons.add),
					tooltip: "Add a game",
					onPressed: () async {
						model.loading = true;
						await model.data.addGame(await SportsBuilder.createGame(context));
						await model.refresh();
						model.loading = false;
					}
				),
			),
			PopupMenuButton(
				icon: const Icon(Icons.sort),
				onSelected: (SortOption option) => model.sortOption = option,
				tooltip: "Sort games",
				itemBuilder: (_) => [
					const PopupMenuItem(
						value: SortOption.chronological,
						child: Text("By date"),
					),
					const PopupMenuItem(
						value: SortOption.sport,
						child: Text("By sport"),
					)
				]
			),
		]
	);

	@override 
	Widget build(BuildContext context) {
		switch(model.sortOption) {
			case SortOption.chronological: return GenericSportsView<int>(
				model: model,
				recents: model.recents,
				upcoming: model.upcoming,
				builder: (int index) => SportsTile(
					model.data.games [index], 
					onTap: !model.isAdmin ? null : () => openMenu(
						context: context,
						index: index,
						model: model,
					)
				),
			);
			case SortOption.sport: return GenericSportsView<MapEntry<Sport, List<int>>>(
				model: model,
				recents: model.recentBySport.entries.toList(),
				upcoming: model.upcomingBySport.entries.toList(),
				builder: (MapEntry<Sport, List<int>> entry) => Column(
					children: [
						const SizedBox(height: 15),
						Text(SportsGame.capitalize(entry.key)),
						for (final int index in entry.value) 
							SportsTile(
								model.data.games [index], 
								onTap: !model.isAdmin ? null : () => openMenu(
									context: context, 
									index: index,
									model: model
								)
							),
						const SizedBox(height: 20),
					]
				)
			);
		}
	}
}
