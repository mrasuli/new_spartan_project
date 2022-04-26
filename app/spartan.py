class Spartans:

    def __init__(self, sp_id, f_n, l_n, b_y, b_m, b_d, course, stream):
        self.spartan_id = sp_id
        self.first_name = f_n
        self.last_name = l_n
        self.birth_year = b_y
        self.birth_month = b_m
        self.birth_day = b_d
        self.sp_course = course
        self.sp_stream = stream

    def __str__(self):
        return f"'spartan_id': '{self.spartan_id}', 'first_name': '{self.first_name}', 'last_name': '{self.last_name}', 'birth_year': '{self.birth_year}', 'birth_month':'{self.birth_month}', 'birth_day': '{self.birth_day}', 'course':'{self.sp_course}', 'stream': '{self.sp_stream}'"


    def get_spartan_id(self):
        return self.spartan_id

    def get_first_name(self):  # retrieving a value
        return self.first_name

    def get_last_name(self):
        return self.last_name

    def get_birth_year(self):
        return self.birth_year

    def get_birth_month(self):
        return self.birth_month

    def get_birth_day(self):
        return self.birth_day

    def get_sp_course(self):
        return self.sp_course

    def get_sp_stream(self):
        return self.sp_stream

    def set_ids(self, sp_id):
        self.spartan_id = sp_id

    # to reassign the value to a new value, this is also called encapsulation, you want protect the data
    def set_first_name(self, first_name):
        self.first_name = first_name

    def set_last_name(self, last_name):
        self.last_name = last_name

    def set_birth_year(self, birth_year):
        self.birth_year = birth_year

    def set_birth_month(self, birth_month):
        self.birth_month = birth_month

    def set_birth_day(self, birth_day):
        self.birth_day = birth_day

    def set_sp_course(self, sp_course):
        self.sp_course = sp_course

    def set_sp_stream(self, sp_stream):
        self.sp_stream = sp_stream
