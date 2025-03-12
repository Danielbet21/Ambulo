import sys
import subprocess

def run_command(command):
    print(f"Running: {command}")
    result = subprocess.run(command, shell=True)
    if result.returncode != 0:
        print(f"Command failed: {command}")
        sys.exit(result.returncode)

def update_shai(): # sync the shai branch with alpha branch
    #stage 1:
    run_command("git checkout shai")
    run_command("git pull origin alpha")
    run_command("git push origin shai")
    
def add_commit_push(addArgument, commitMessage):# commit the changes in shai branch
    run_command("git checkout shai")
    run_command("git status")
    print("Are you sure you want to add the following files?")
    option = input("Do you want to continue? (y/n): ")
    if (option == "Y" or option == "y" or option == "yes" or option == "YES"):
        print("Adding the files")
        run_command("git add "+addArgument)
        run_command('git commit -m "{}"'.format(commitMessage))
        run_command("git push origin shai")

def sync_alpha_shai_with_main():
    run_command("git checkout shai")
    run_command("git pull origin main")
    run_command("git push origin shai")
    #------------------------------------
    run_command("git checkout alpha")
    run_command("git pull origin main") # Pulls main into alpha
    run_command("git push origin alpha")
    run_command("git checkout shai")

def pull_from_shai():
    # Get the current branch
    result = subprocess.run("git branch --show-current", shell=True, capture_output=True, text=True)
    current_branch = result.stdout.strip()
    print(f"Current branch: {current_branch}")
    
    # If not on shai branch, checkout shai first
    if current_branch != "shai":
        run_command("git checkout shai")
    
    # Pull from remote shai branch
    run_command("git pull origin shai")
    print("Successfully pulled latest changes from shai branch")


def validate(num):
    print("------------------------------------")
    print("Welcome to the Git Workflow")
    if (num == 1):
        print("Stage 1:")
        print("Sync shai branch with alpha branch")
    elif (num == 2):
        print("Stage 2: Workflow:")
        print("Commit & push the changes in shai branch") 
    elif (num == 3):
        print("Stage 3:")
        print("Sync shai branch & alpha branch with main branch")
    elif (num == 4):
        print("Stage 4:")
        print("Pull the latest changes from shai branch")
    else:
        print("Invalid option")
    
    option = "n"
    
    option = input("Do you want to continue? (y/n): ")
    if (option == "y" or option == "Y" or option == "yes" or option == "YES"):
        return True
    else:
        print("goodbye")
        exit()


if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Usage: python update_branch.py [shai|sync_alpha_shai_with_main|add_commit_push]")
        sys.exit(1)

    task = sys.argv[1].lower()

    if task == "shai":
        validate(1)
        validate(1) # this is not a mistake, we need to validate twice

        update_shai()
        
    elif task == "sync_alpha_shai_with_main":
        validate(3)
        validate(3) # this is not a mistake, we need to validate twice

        sync_alpha_shai_with_main()
        
    elif task == "add_commit_push":
        validate(2) 
        add_argument = sys.argv[2]
        print("add_argument=",add_argument)
        commit_message = " ".join(sys.argv[3:])  # Join all remaining arguments
        # Validate that neither argument is empty
        print("commit_message=",commit_message)


        if not add_argument.strip() or not commit_message.strip():
            print("Error: Files name or Commit msg cannot be empty.")
            sys.exit(1)

        add_commit_push(add_argument, commit_message)
        
    elif task == "pull_from_shai":
        validate(4)
        pull_from_shai()

    else:
        print("Invalid option.")
        sys.exit(1)
