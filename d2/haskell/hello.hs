import System.IO

parseLine :: String -> [Int]
parseLine line = map read (words line)

readFileAsIntLists :: FilePath -> IO [[Int]]
readFileAsIntLists filePath = do
    contents <- readFile filePath
    let linesOfInts = map parseLine (lines contents)
    return linesOfInts

isSafe :: [Int] -> Bool
isSafe levels = isIncreasing levels || isDecreasing levels
  where
    isIncreasing (x:y:xs) = (y - x) >= 1 && (y - x) <= 3 && isIncreasing (y:xs)
    isIncreasing _ = True
    isDecreasing (x:y:xs) = (x - y) >= 1 && (x - y) <= 3 && isDecreasing (y:xs)
    isDecreasing _ = True

canBeMadeSafe :: [Int] -> Bool
canBeMadeSafe levels = any isSafe (removeOne levels)
  where
    removeOne xs = [take i xs ++ drop (i + 1) xs | i <- [0..length xs - 1]]

countSafeReports :: [[Int]] -> Int
countSafeReports reports = length $ filter isReportSafe reports
  where
    isReportSafe report = isSafe report || canBeMadeSafe report

main :: IO ()
main = do
    let filePath = "input" 
    linesOfInts <- readFileAsIntLists filePath
    let count = countSafeReports linesOfInts
    print count
