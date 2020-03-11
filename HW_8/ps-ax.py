import os

pid_list = os.listdir('/proc')
for num in pid_list:
        if num.isdigit():
            stat = open("/proc/" + num + "/stat", 'rt')
            stat_line = stat.readline()
            ps_stat = stat_line.split()
            stat.close()
            cmd = open("/proc/" + num + "/cmdline", 'rt')
            cmdline = cmd.readline()
            if cmdline == '':
                cmd = open("/proc/" + num + "/comm", 'rt')
                cmdline = cmd.readline()
                cmdline = cmdline.rstrip()
                cmdline = "[" + cmdline + "]"
                cmd.close()
            print("{:6} {:6} {:6} {:6}".format(num, ps_stat[6], ps_stat[2], cmdline))
