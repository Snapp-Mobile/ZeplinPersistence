# ``ZeplinPersistence``

@Metadata {
    @PageImage(purpose: icon, source:"ZeplinPersistance-logo")
}

A Swift Package that wraps up a CoreData container for persisting user's notifications

## Overview

ZeplinPersistence handles data storage for the Zeplin Mobile app. It wraps CoreData for storing notifications and manages authentication tokens through the iOS keychain.

The ``PersistenceController`` sets up a CoreData container that uses app groups for sharing data between the main app and extensions. It supports both in-memory stores for testing and persistent stores for production. The ``TokenRepository`` is an actor that handles token storage and refreshing, waiting for protected data availability when the device is locked.

Different app targets like widgets or notification extensions get their own configuration through ``AppTarget`` to handle security and data sharing.

## Topics
