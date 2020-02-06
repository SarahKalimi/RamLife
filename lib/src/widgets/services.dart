import "package:flutter/material.dart";

import "package:ramaz/models.dart";
import "package:ramaz/services.dart";
import "package:ramaz/services_collection.dart";

class Services extends InheritedWidget {
	static Services of(
		BuildContext context, 
	) => context.inheritFromWidgetOfExactType(Services);

	final ServicesCollection services;
	final Reader reader;
	final Preferences prefs;

	Services({
		this.services,
		@required Widget child,
	}) :
		reader = services.reader,
		prefs = services.prefs,
		super (child: child);

	Notes get notes => services.notes;
	Schedule get schedule => services.schedule;
	Sports get sports => services.sports;

	/// This instance will never be rebuilt with new data
	@override
	bool updateShouldNotify(_) => false;
}
