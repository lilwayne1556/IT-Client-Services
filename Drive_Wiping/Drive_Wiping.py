from datetime import datetime

def main():
    drives = open("Drive Wiping - Drives to Wipe.csv", "r")
    call = ""
    for drive in drives:
        cols = drive.split(",")
        if "/" not in cols[0] or cols[0] == "1/30/1900":
            continue

        today = datetime.now()
        today_date = today.strftime("%m/%d/%Y")
        computer_name = cols[3]
        contact_name = cols[4]
        first_contact_date = datetime.strptime(cols[1], "%m/%d/%Y")
        num_contacts = 0

        if cols[10]:
            num_contacts += 1
        if cols[11]:
            num_contacts += 1
        if cols[12]:
            num_contacts += 1
        if today > first_contact_date:
            if num_contacts == 3 or cols[13]:
                print("You can destory", computer_name)
            elif num_contacts == 2:
                call += computer_name + ": " + contact_name + "\n"
            elif num_contacts <= 1:
                if "?" in computer_name:
                    continue
                
                template = open("Emails/template.txt", "r")
                email = ""
                for line in template:
                    if "<0>" in line:
                        email += line.replace("<0>", contact_name.split(" ")[0])
                    elif "<1>" in line:
                        email += line.replace("<1>", cols[1])
                    elif "<2>" in line:
                        email += line.replace("<2>", computer_name)
                    elif "<3>" in line:
                        days = "90"
                        if "FM-" in computer_name.upper() or "ATHL-" in computer_name.upper():
                            days = "120"
                        email += line.replace("<3>", days)
                    elif "<4>" in line:
                        contact_amount = "first"
                        if num_contacts == 1:
                            contact_amount = "second"
                        email += line.replace("<4>", contact_amount)
                    else:
                        email += line
                    email_file = open("Emails/" + computer_name + ".txt", "w")
                    email_file.write(email)
                    email_file.close()

    print("\nThose to call")
    print(call)

main()
