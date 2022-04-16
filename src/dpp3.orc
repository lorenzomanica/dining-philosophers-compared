{- misra-philosopher.orc
 -
 - The "hygenic solution to the diners problem", described in
 - K. M. Chandy and J. Misra. 1984. The drinking philosophers problem.
 - ACM Trans. Program. Lang. Syst. 6, 4 (October 1984), 632-646.
 -}

-- Use a Scala set implementation.
-- Operations on this set are _not_ synchronized.
import class ScalaSet = "scala.collection.mutable.HashSet"

import class System = "java.lang.System"

{-
Make a set initialized to contain
the items in the given list.
-}
def Set[A](items :: List[A]) = ScalaSet[A]() >s> joinMap(s.add, items) >> s


type Message = (String, lambda((String, lambda(Top) :: Signal)) :: Signal)
type Xmitter = lambda(Message) :: Signal


val TIME_EATING = 100
val TIME_THINKING = 500

{-
Start a philosopher process; never publishes.

name: identify this process in status messages
mbox: our mailbox
missing: set of neighboring philosophers holding our fork
-}
def philosopher(name :: Integer, ctr :: Array, mbox :: Channel[Message], missing :: ScalaSet[Xmitter], iterations :: Integer, done :: Semaphore) :: Bot =
  val send = mbox.put
  val receive = mbox.get
  -- deferred requests for forks
  val deferred = Channel[Xmitter]()
  -- forks we hold which are clean
  val clean = Set[Xmitter]([])

  def sendFork(p :: Xmitter) =
    missing.add(p) >>
    p(("fork", send))

  def requestFork(p :: Xmitter) =
    clean.add(p) >>
    p(("request", send))

  -- While thinking, start a timer which
  -- will tell us when we're hungry
  def digesting() :: Bot =
      {- Println(name + " thinking") >> -}
      thinking()
    | Rwait(TIME_THINKING) >>
      send(("rumble", send)) >>
      stop

  def thinking() :: Bot =
    def on(("rumble", _) :: Message) =
      {- Println(name + " hungry") >> -}
      map(requestFork, missing.toList() :!: List[Xmitter]) >>
      hungry()
    def on(("request", p)) =
      sendFork(p :!: Xmitter) >>
      thinking()
    on(receive())

  def hungry() :: Bot =
    def on(("fork", p) :: Message) =
      missing.remove(p :!: Xmitter) >>
      (
        if missing.isEmpty() then
          {- Println(name + " eating") >> -}
          eating()
        else hungry()
      )
    def on(("request", p)) =
      if clean.contains(p :!: Xmitter) then
        deferred.put(p :!: Xmitter) >>
        hungry()
      else
        sendFork(p :!: Xmitter) >>
        requestFork(p :!: Xmitter) >>
        hungry()
    on(receive())

  def eating() :: Bot =
    clean.clear() >>
    Rwait(TIME_EATING) >>
    map(sendFork, deferred.getAll()) >>
    ctr(name)? >x> ctr(name):=x+1 >>
    (if (ctr(name)? <: iterations + 1) 
      then digesting() 
      else done.release() >> stop)

  digesting()

{-
Create an NxN 4-connected grid of philosophers.  Each philosopher holds the
fork for the connections below and to the right (so the top left philosopher
holds both its forks).
-}
def printArray(arr :: Array) =
  arr(0)? + " " + arr(1)? + " " + arr(2)? + " " + arr(3)? + " " + arr(4)?
  | Rwait(50) >> printArray(arr)

def philosophers(n :: Integer) =
  {- channels -}
  val cs = Table(n, lambda (_) = Channel())
  
  val c = Channel()
  val done = Semaphore(0)
  val ctr = fillArray(Array(n), lambda(_) = 0)

  val t = System.currentTimeMillis()

  def watcher() = 
    repeat(c.get) <<
      printArray(ctr) >x> c.put(x) >> stop
      | done.acquire() >> c.closeD() >> Println("Time: " + (System.currentTimeMillis() - t) + "ms")

  philosopher(0, ctr, cs(0), Set[Xmitter]([]), 10, done)
  | for(1, n-1) >i>
    philosopher(i, ctr, cs(i), Set[Xmitter]([cs(i-1).put]), 10, done)
  | philosopher(n-1, ctr, cs(n-1), Set[Xmitter]([cs(n-2).put, cs(0).put]), 10, done)
  | Println(t) >> watcher()
  

philosophers(5)