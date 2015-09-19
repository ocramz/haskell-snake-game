module Snake where

import qualified Graphics.Gloss.Interface.Pure.Game as G

main :: IO ()
main = do
    let world = initialWorld

    G.play
        (displayMode world)
        backgroundColor
        stepRate
        world
        drawWorld
        handleEvent
        handleStep

--

displayMode :: World -> G.Display
displayMode world = G.InWindow "Snake" (resolution world) (0, 0)

backgroundColor :: G.Color
backgroundColor = G.white

stepRate :: Int
stepRate = 1

initialWorld :: World
initialWorld = NewWorld
    { resolution = (512, 512)
    , direction = North
    , scale = 10
    , snake = [(0, 1), (0, 0), (0, -1)]
    }

drawWorld :: World -> G.Picture
drawWorld world = G.pictures
    [ drawBounds world
    , drawSnake world
    ]

handleEvent :: G.Event -> World -> World
handleEvent event world = case event of
    G.EventResize newResolution -> handleResize newResolution world
    G.EventKey key state _ _ -> handleKey key state world
    _ -> world

handleStep :: Float -> World -> World
handleStep _time world =
    let newSnake@((x, y) : _) = init (snake world)
    in  case direction world of
        North -> world { snake = (x, y + 1) : newSnake }
        East -> world { snake = (x + 1, y) : newSnake }
        South -> world { snake = (x, y - 1) : newSnake }
        West -> world { snake = (x - 1, y) : newSnake }

--

drawBounds :: World -> G.Picture
drawBounds world =
    let x = size world
    in  G.rectangleWire x x

drawSnake :: World -> G.Picture
drawSnake world = G.pictures (map (\ p -> drawBox p world) (snake world))

drawBox :: (Int, Int) -> World -> G.Picture
drawBox (x, y) world =
    let s = size world / fromIntegral (scale world)
        x' = s * fromIntegral x
        y' = s * fromIntegral y
    in  G.translate x' y' (G.rectangleSolid s s)

--

handleResize :: (Int, Int) -> World -> World
handleResize newResolution world = world { resolution = newResolution }

handleKey :: G.Key -> G.KeyState -> World -> World
handleKey key state world = case (key, state) of
    (G.SpecialKey G.KeyUp, G.Down) -> world { direction = North }
    (G.SpecialKey G.KeyRight, G.Down) -> world { direction = East }
    (G.SpecialKey G.KeyDown, G.Down) -> world { direction = South }
    (G.SpecialKey G.KeyLeft, G.Down) -> world { direction = West }
    _ -> world

--

data World = NewWorld
    { resolution :: (Int, Int)
    , direction :: Direction
    , scale :: Int
    , snake :: [(Int, Int)]
    } deriving (Eq, Ord, Read, Show)

size :: (Num a) => World -> a
size world =
    let (width, height) = resolution world
    in  fromIntegral (min width height)

data Direction
    = North
    | East
    | South
    | West
    deriving (Bounded, Enum, Eq, Ord, Read, Show)
