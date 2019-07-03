# The Fuck settings file
#
# The rules are defined as in the example bellow:
#
# rules = ['cd_parent', 'git_push', 'python_command', 'sudo']
#
# The default values are as follows. Uncomment and change to fit your needs.
# See https://github.com/nvbn/thefuck#settings for more information.
#

alter_history = True
debug = False
exclude_rules = []
history_limit = None
no_colors = False
num_close_matches = 2
require_confirmation = True
priority = {}
slow_commands = []
wait_command = 3
wait_slow_command = 15

rules = [
    'apt_get',
    'apt_get_search',
    'apt_invalid_operation',
    'cat_dir',
    'cd_correction',
    'cd_mkdir',
    'cd_parent',
    'chmod_x',
    'cp_omitting_directory',
    'dirty_untar',
    'dirty_unzip',
    # 'docker_login',
    # 'docker_not_command',
    'dry',
    'fix_alt_space',
    'fix_file',
    'git_add',
    'git_branch_delete',
    'git_branch_exists',
    'git_branch_list',
    'git_checkout',
    'git_commit_amend',
    'git_commit_reset',
    'git_fix_stash',
    'git_help_aliased',
    'git_merge',
    'git_merge_unrelated',
    'git_not_command',
    'git_pull',
    'git_pull_clone',
    'git_push',
    'git_push_different_branch_names',
    'git_push_pull',
    'git_push_without_commits',
    'git_rebase_no_changes',
    'git_remote_delete',
    'git_rm_local_modifications',
    'git_rm_recursive',
    'git_rm_staged',
    'git_rebase_merge_dir',
    'git_remote_seturl_add',
    'git_stash',
    'git_two_dashes',
    'grep_arguments_order',
    'grep_recursive',
    # 'gulp_not_task',
    'has_exists_script',
    'heroku_multiple_apps',
    'heroku_not_command',
    'history',
    # 'ifconfig_device_not_found',
    # 'java',
    'javac',
    'long_form_help',
    'ln_s_order',
    'ls_all',
    'man',
    # 'mercurial',
    'missing_space_before_subcommand',
    'mkdir_p',
    # 'npm_missing_script',
    'npm_run_script',
    'npm_wrong_command',
    'no_command',
    'no_such_file',
    # 'port_already_in_use',
    'python_command',
    'python_execute',
    'quotation_marks',
    'path_from_history',
    'rm_dir',
    'scm_correction',
    'sed_unterminated_s',
    'ssh_known_hosts',
    'sudo',
    'sudo_command_from_user_path',
    'systemctl',
    'touch',
    'unsudo',
]
