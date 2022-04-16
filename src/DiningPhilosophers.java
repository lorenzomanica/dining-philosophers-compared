import java.util.concurrent.Semaphore;

public class DiningPhilosophers {

    public static final int N = 5;
    public static final int ROUNDS = 10;

    public static final int PHIL_THINKING = 0;
    public static final int PHIL_HUNGRY = 1;
    public static final int PHIL_EATING = 2;

    private static final int FORK_FREE = -1;

    private static final long THINK_TIME = 500;
    private static final long EAT_TIME = 100;

    public static void main(String[] args) {
        DiningPhilosophers program = new DiningPhilosophers();
        long t1 = System.currentTimeMillis();
        program.run();
        System.out.println(System.currentTimeMillis() - t1);
    }

    int[] philosopher;
    Semaphore[] fork;
    int[] forkMap;
    int[] iterations;

    public DiningPhilosophers() {
        philosopher = new int[N];
        forkMap = new int[N];
        fork = new Semaphore[N];
        iterations = new int[N];

        for (int i = 0; i < N; i++) {
            fork[i] = new Semaphore(1);
            forkMap[i] = FORK_FREE;
        }
    }

    public void run() {
        try {
            for (int n = 0; n < ROUNDS; n++) {
                for (int i = 0; i < N; i++) {
                    printStates();
                    think(i);
                    philosopher[i] = PHIL_HUNGRY;
                    takeForks(i);
                    eat(i);
                    leaveForks(i);
                    philosopher[i] = PHIL_THINKING;
                }
            }
        } catch (Exception e) {
            System.out.println("End of program");
        }
    }

    private void printStates() {
        StringBuilder sb = new StringBuilder();
        for (int k = 0; k < N; k++) {
            sb.append(iterations[k]).append(" ");
        }
        System.out.println(sb);
    }

    private void think(int i) throws InterruptedException {
        philosopher[i] = PHIL_THINKING;
        Thread.sleep(THINK_TIME);
    }


    private void takeForks(int i) throws InterruptedException {
        fork[i].acquire();
        forkMap[i] = i;
        if (fork[rightFork(i)].tryAcquire()) {
            forkMap[rightFork(i)] = i;
        } else {
            fork[i].release();
            forkMap[i] = FORK_FREE;
        }
    }

    private int rightFork(int i) {
        return (i + 1) % N;
    }

    private void eat(int i) throws InterruptedException {
        if (forkMap[i] == i && forkMap[rightFork(i)] == i) {
            philosopher[i] = PHIL_EATING;
            Thread.sleep(EAT_TIME);
            iterations[i]++;
        }
    }

    private void leaveForks(int i) {
        forkMap[rightFork(i)] = FORK_FREE;
        fork[rightFork(i)].release();
        forkMap[i] = FORK_FREE;
        fork[i].release();
    }
}
