from lib import data
from lib import utils
from lib.students import reader as student_reader
from lib import services

from collections import defaultdict
#from firebase_admin import delete_app

if __name__ == '__main__':
	utils.logger.info("Indexing students...")


	student_courses = student_reader.read_student_courses()
	students = student_reader.read_students()
	print("length of students", len(students))
	periods = utils.logger.log_value("section periods", student_reader.read_periods)
	print("number of periods", len(periods))
	homeroom_locations = defaultdict(lambda: "Unavailable")
	# utils.logger.info("Homeroom locations", homeroom_locations)
	semesters = utils.logger.log_value("semesters", student_reader.read_semesters)
	print("length of semesters: ", len(semesters))

	
	schedules, homerooms, seniors = utils.logger.log_value(
		"schedules", lambda: student_reader.get_schedules(
			students = students,
			periods = periods, 
			student_courses = student_courses,
			semesters = semesters,
		)
	)

	student_reader.set_students_schedules(
		schedules = schedules,
		homerooms = homerooms, 
		homeroom_locations = homeroom_locations,
	)
	students_with_schedules = list(schedules.keys())
	# utils.logger.info("Student schedules", students_with_schedules)
	print(len(students_with_schedules))
	print(schedules.keys())

	# data.User.verify_schedule(students_with_schedules)
	"""
	test_users = [
		data.User.empty(
			email = tester ["email"],
			first = tester ["first"], 
			last = tester ["last"], 
		)
		for tester in utils.constants.testers
	]
	utils.logger.verbose(f"Found {len(test_users)} testers")
	utils.logger.info("Testers", test_users)
	students_with_schedules.extend(students)
	"""
	utils.logger.info("Finished processing students")

	if utils.args.should_upload:
		utils.logger.log_progress(
			"data upload", 
			lambda: services.upload_users(students_with_schedules)
		)
	else: utils.logger.warning("Did not upload student data. Use the --upload flag.")

	utils.logger.info(f"Processed {len(students_with_schedules)} users.")


