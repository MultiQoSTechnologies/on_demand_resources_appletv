# On-Demand Resources Apple TV

On-demand resources are app contents that are hosted on the App Store and are separate from the related app bundle that you download. They enable smaller app bundles, faster downloads, and richer app content. The app requests sets of on-demand resources, and the operating system manages downloading and storage. The app uses the resources and then releases the request. After downloading, the resources may stay on the device through multiple launch cycles, making access even faster.

tvOS App bundle size is 4GB.

Hosted on-demand resources size is 20GB.

# How On-Demand Resources Work
Request: The app requests specific resources, grouped into asset packs.
Download: The operating system downloads the requested resources in the background.

Use: The app accesses the downloaded resources for immediate use.
Release: When no longer needed, the app releases the resources, freeing up device storage.
Persistence: Resources remain on the device for subsequent app launches, ensuring faster access.

# Limitations
Asset packs must be under 512 MB in size.
The total size of all hosted on-demand resources for your app can be up to 20GB.
Proper management of resources is necessary to ensure efficient use of storage and data.

# Reference
For more detailed information on how to implement and manage on-demand resources in your tvOS app, please refer to the [OnDemandResourcesGuide](https://developer.apple.com/library/archive/documentation/FileManagement/Conceptual/On_Demand_Resources_Guide/)

# Project Created & Maintained By
[MultiQoS](https://multiqos.com/)

# Capability
1. Selecte target -> Build setting -> enable on demand resources -> Yes

![Screenshot 2025-02-04 at 2 29 09 PM](https://github.com/user-attachments/assets/bdbef99b-2d39-4b34-ad02-3007f33d4c54)

2. Selecte target -> Resource Tages -> click on plus icon and write the tag name

![Screenshot 2025-02-04 at 2 27 56 PM](https://github.com/user-attachments/assets/3035b0cc-83d1-4a3c-8b51-6088f9ca3746)

3. Select the resource and assign the tag 

![Screenshot 2025-02-04 at 2 28 30 PM](https://github.com/user-attachments/assets/6a1eded8-f022-4ea8-a983-bab3624b5deb)



