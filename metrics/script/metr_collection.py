import os
import csv

#============================================================= parsers
def parse_area(REPORT, DESIGN_NAME):
    f = open(REPORT, 'r')
    s = f.readline()
    while DESIGN_NAME not in s or 'Module' in s:
        s = f.readline()
    s = s.split()
    area = float(s[-3])
    f.close()
    return area

def parse_timing(REPORT):
    f = open(REPORT, 'r')
    s = f.readline()
    while 'Path 1:' not in s:
        s = f.readline()
    s = s.split()
    WNS = float(s[3].strip('('))
    f.close()
    return WNS

def parse_sim_time(REPORT):
    f = open(REPORT, 'r')
    s = f.readline()
    while 'Test simulation cycles:' not in s or 'Module' in s:
        s = f.readline()
    s = s.split(':')
    f.close()
    return int(s[1])
#============================================================= parsers : end

#============================================================= calc
def calc_fmax(FREQ,WNS):
    PERIOD = 1/(FREQ) * 10**3
    return 1/(PERIOD-WNS)*1000
#============================================================= calc : end

#============================================================= printer
def result_print(fmax, sim_time, area, perf):
    separator = '\n===============================\n'

    result  = separator
    result += '\nFmax:\t\t'    + format(fmax, '.3f').rjust(12) + '\n'
    result += 'Sim time:\t' + format(sim_time, '.3f').rjust(12) + '\n'
    result += 'Area:\t\t'    + format(area, '.3f').rjust(12) + '\n'
    result += 'Perf:\t\t' + format(perf, '.3f').rjust(12) + '\n'

    result += separator
    print(result)
#============================================================= printer : end

#============================================================= main
DIR         = os.environ.get('GIT_HOME')
DESIGN_NAME = os.environ.get('DESIGN_NAME')
FREQ        = int(os.environ.get('CLK'))

AREA_REP    = DIR + '/syn/out/reports/area.rpt'
TIMING_REP  = DIR + '/syn/out/reports/' + DESIGN_NAME + '_all_timing_1000.rpt'
SIM_REP     = DIR + '/dv/build/out/rtl_run.log'
RESULT_FILE = DIR + '/metrics/metrics.txt'

WNS  = parse_timing(TIMING_REP)
fmax = calc_fmax(FREQ, WNS)

area = parse_area(AREA_REP, DESIGN_NAME)

sim_time = parse_sim_time(SIM_REP)

perf = fmax/sim_time

result_print(fmax, sim_time, area, perf)

csv_row = [fmax, sim_time, area, perf]

with open(RESULT_FILE, 'w') as f:
    csv_writer = csv.writer(f)
    csv_writer.writerow(csv_row)
