// One card: the way a single restaurant looks in the list.
import 'package:flutter/material.dart';
import '../models/resturant.dart';

class RestaurantCard extends StatelessWidget {
  final Restaurant restaurant;

  const RestaurantCard({super.key, required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, '/detail', arguments: restaurant);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: restaurant.id,
              child: Image.network(
                restaurant.imageUrl,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const SizedBox(
                    height: 180,
                    child: Center(child: Icon(Icons.broken_image, size: 60)),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    restaurant.name,
                    style: Theme.of(context).textTheme.titleLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(restaurant.cuisine),
                  Text(
                    restaurant.address,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// NOTES
// Extracting Widgets: one card lives in its own file, and Home and Nearby
// just repeat it for each restaurant.

// '../models/resturant.dart': the ../ means "go up one folder, out of
// widgets, then into models."

// Hero(tag: restaurant.id): the Detail screen has a Hero with the same tag,
// so the photo "flies" from the card into the Detail page (the animation).

// Image.network(restaurant.imageUrl) shows the photo. It downloads the image
// from the link saved in the restaurant list (resturant.dart).
//   fit: BoxFit.cover fills the space neatly without stretching.
//   errorBuilder: if the link is broken, show a "broken image" icon
//   instead of crashing.

// maxLines: 1 + TextOverflow.ellipsis keep long names and addresses on one
// line, ending with "..." so the card fits in narrow grid columns.

// InkWell makes the whole card tappable, with a ripple effect. Tapping
// opens the Detail screen and passes the restaurant with arguments:
// (Passing Route Data lesson).

// clipBehavior: Clip.antiAlias keeps the photo inside the rounded corners.
// titleLarge uses the theme's big title size ("correct text sizes" marks).
