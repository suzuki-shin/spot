{-# LANGUAGE OverloadedStrings, DeriveDataTypeable #-}
{-# LANGUAGE TypeSynonymInstances, FlexibleInstances #-}
module App
    ( app
    ) where

import Control.Applicative ((<$>))
import Control.Monad.Trans
import qualified Data.Text as T
import Data.Text.Lazy.Encoding (decodeUtf8)
import Data.Data
import Text.Hastache
import Text.Hastache.Context
import Web.Scotty hiding (body)
import qualified Database.Persist.Sqlite as P
import DB

data Info = Info {
    name    :: String
  , unread  :: Int
  } deriving (Data, Typeable)

mustache :: (Data a, Typeable a) => FilePath -> a -> ActionM ()
mustache path context = do
  body <- liftIO $ decodeUtf8 <$> hastacheFile defaultConfig path (mkGenericContext context)
  html body

withRescue :: ActionM () -> ActionM ()
-- TODO Return proper status code
withRescue = flip rescue text

app :: T.Text -> ScottyM ()
app db = do
    -- #TODO Get environment from command line argument like "-e production"
    let runDB = runDB' db

    get "/" $
        mustache "views/home.mustache" $ Info "Haskell" 100

    get "/spots" $ withRescue $ do
        spots <- runDB $ map P.entityVal <$> P.selectList ([] :: [P.Filter Spot]) []
        json spots

    post "/spots" $ withRescue $ do
        spotData <- jsonData :: ActionM Spot
        spotId <- runDB $ P.insert spotData
        spot <- runDB $ P.get spotId
        json spot
