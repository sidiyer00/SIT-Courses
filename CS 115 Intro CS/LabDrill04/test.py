import numpy as np
import matplotlib.pyplot as plt

"""
plot_MAB
input m: number of arms
input N: number of trials
input n_set: set of # of pulls
input t_set: set of max # explore pulls
input f_set: average fraction of max wealth achieved
plot the results and save the file
"""

"""
    plot the results for each value t in t_set
    x-axis is the number of trials, given by n_set
    y-axis is the average fraction of wealth obtained
    use zip to allow labels for each value of t in t_set
    """
#define your function below with function name provided above

def plot_MAB(m,n,n_set,t_set,f_set,filename):
    plt.plot(n_set, f_set)
    plt.show()
    
   
"""
explore_MAB: compute # of trial pulls k <= t of each arm given n pulls
input m: number of arms
input n: number of pulls
input t: max # explore pulls
return: # of explore pulls of each arm
note: n/m is the number of trials per arm if we spend equal effort on each arm
if n/m < t then it is not possible to pull each arm t times
if n/m < t then pull each arm int(1.*n/m) times
else, if n/m > t, then we *can* afford to pull each arm t times
and will have n - t * m pulls left over for pulling the estimated best arm
"""
def explore_MAB(m, n, t):
    return int(1.*n/m) if n/m < t else t

"""
play_MAB_ave: call play_MAB(m,n,t) N times and average results
input m: number of arms
input n: number of pulls
input t: max # explore pulls
input N: number of independent trials
return average over valid trials
"""
def play_MAB_ave(m, n, t, N):
    # call play_MAB N times and store results in res
    res = [play_MAB(m, n, t) for _ in range(N)]
    """
    as explained in play_MAB comments, not all trials are successful
    unsuccessful trial return a value of -1, while successful trials
    return a value between 0 and 1, the fraction of wealth obtained over
    the maximum possible wealth obtainable
    res_cal sums the outcomes of trials with r >= 0
    res_cnt counts the number of trials with r >= 0
    """
    res_val = sum([r for r in res if r >= 0])
    res_cnt = sum([1 for r in res if r >= 0])
    # return the average value of the successful trials
    return res_val / res_cnt


"""
play_MAB: play MAB with m arms using n pulls with t max explore pulls per arm
input m: number of arms
input n: number of pulls
input t: max # explore pulls
return: ratio of wealth earned over wealth pulling best arm
"""
def play_MAB(m, n, t):
    # call create_MAB to obtain the win probabilities p and the outcomes M
    p, M = create_MAB(m, n)
    # call explore_MAB to determine the number of trials per arm, k
    k = explore_MAB(m, n, t)
    """
    access the specific entries of each row a of the outcomes M for each arm
    for arm a = 0,...,m-1 we access k entries
    starting with index a * k, and ending with index (a+1)*k-1
    then, sum these entries up to get the number of wins from each arm a
    so, w_est is a list of length m, holding # wins on each arm out of k pulls
    """
    w_est = [np.sum(M[a, a*k : (a+1)*k]) for a in range(m)]
    """
    a_est is the best guess for the best arm, based upon the results in w_est
    use the np.where command to obtain the indices in w_est holding the max
    it is possible for there to be multiple maxima, we break ties by choosing
    the maximum with the lowest index
    """
    a_est = np.where(np.array(w_est) == max(w_est))[0][0]
    """
    having tested each of the arms, and guessed the best arm, now use the rest
    of the trials to pull that arm.  As we have used m * k trials exploring,
    we start at trial index m *k and go through the end, i.e., to n-1
    add the sum of wins from these trials to the list w_est using append
    """
    w_est.append(np.sum(M[a_est, m*k : n]))
    """
    now, use np.where to identify the arm with the actual best win probability
    from the list of win probabilities p (break ties by choosing lowest index)
    """
    a_best = np.where(np.array(p) == max(p))[0][0]
    """
    now, suppose you knew the value of p in advance, and then pulled that arm
    for all n trials, yielding the best possible win w_best
    """
    w_best = M[a_best,:]
    """
    it is possible that w_best sums to zero, e.g., if all values of p are
    very small.  In this case, we report a value of -1, and will interpret it
    as a failed trial.  Otherwise, sum up w_est and w_best and return their
    fraction, which represents the fraction of the maximum possible wealth
    obtained without foreknowledge of p
    """
    return np.sum(w_est)/np.sum(w_best) if np.sum(w_best) > 0 else -1

"""
create_MAB: create a MAB with m arms and pull each arm n times
each of the m arms has a win probability pe chosen uniformly
at random over the interval [0,1]
input m: number of arms
input n: number of pulls
return p: list of m arm win probabilities
return M: np.array of dimension m times n of arm pulls
note: every element of M is 1 (win) or 0 (loss)
note: M[a,i] the outcome of pull i (out of n) of arm a (out of m)
"""
def create_MAB(m, n):
    p = np.random.uniform(0, 1, m)
    M = np.array([pull_arm(pe, n) for pe in p])
    return p, M

"""
pull_arm: make n pulls on an arm with win prob. p
input p: probability of win
input n: number of pulls
return: a np.array of length n
note: 1 represents win and 0 represents loss
"""
def pull_arm(p, n):
    # return random length n list with values {0,1}
    # each entry equals 1 w.p. p or 0 w.p. 1-p
    a = np.random.choice([1,0], p=[p, 1-p], size=n)
    print(a)
    return a

# define m: number of arms
m = 2

# define N: number of trials
N = 20

# define n_set: set of # of pulls (20, 40, 60, ..., 580, 600)
n_set = 60

# define t_set: set of max # explore pulls
t_set = 100

# define f_set: average fraction of max wealth achieved
f_set = 10
# assign a filename
plot_filename = "HW2.pdf"
# plot the results
plot_MAB(m,N,n_set,t_set,f_set,plot_filename)
    