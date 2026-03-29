import 'package:flutter/material.dart';

class _Place {
  final String name;
  final String imageUrl;
  final String badge;
  final String distance;
  final String duration;

  const _Place({
    required this.name,
    required this.imageUrl,
    required this.badge,
    required this.distance,
    required this.duration,
  });
}

const _places = [
  _Place(
    name: 'สระพลาสติก มข.',
    imageUrl: 'https://i.ytimg.com/vi/wTZuouZAoP0/maxresdefault.jpg',
    badge: 'NEAR YOU',
    distance: '3.2 km',
    duration: '35 min.',
  ),
  _Place(
    name: 'อุทยานสวนเกษตร มข.',
    imageUrl:
        'https://www.kku.ac.th/wp-content/uploads/2023/12/IMG_0832-scaled.jpg',
    badge: 'POPULAR',
    distance: '5.32 km',
    duration: '1 hr.',
  ),
  _Place(
    name: 'สนามกีฬา มข.',
    imageUrl:
        'https://sdg.kku.ac.th/wp-content/uploads/2024/11/%E0%B8%AA%E0%B8%99%E0%B8%B2%E0%B8%A1%E0%B8%81%E0%B8%B5%E0%B8%AC%E0%B8%B2-50-%E0%B8%9B%E0%B8%B5-%E0%B8%A1%E0%B8%82-4.jpg',
    badge: 'NEAR YOU',
    distance: '2.0 km',
    duration: '20 min.',
  ),
  _Place(
    name: 'ทางวิ่งรอบมข.',
    imageUrl:
        'https://kkdata.khonkaenlink.info/wp-content/uploads/2023/03/234F312F-337A-4BDB-B0F1-37B46D728A3C.jpeg',
    badge: 'POPULAR',
    distance: '8.5 km',
    duration: '1.5 hr.',
  ),
];

class SuggestedPlacesSection extends StatelessWidget {
  const SuggestedPlacesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Suggested Places:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              GestureDetector(
                onTap: () {},
                child: Text(
                  'SEE MORE →',
                  style: TextStyle(
                    color: primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Cards
        SizedBox(
          height: 200,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _places.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) => _PlaceCard(place: _places[i]),
          ),
        ),
      ],
    );
  }
}

class _PlaceCard extends StatelessWidget {
  final _Place place;
  const _PlaceCard({required this.place});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final isNearYou = place.badge == 'NEAR YOU';

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: 200,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image
            Image.network(
              place.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: Colors.grey[800]),
            ),

            // Gradient overlay
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black87],
                  stops: [0.4, 1.0],
                ),
              ),
            ),

            // Badge
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isNearYou ? primary : Colors.black54,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  place.badge,
                  style: TextStyle(
                    color: isNearYou ? Colors.black : Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Place info
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.straighten,
                        color: Colors.white70,
                        size: 13,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        place.distance,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Icon(
                        Icons.access_time,
                        color: Colors.white70,
                        size: 13,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        place.duration,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
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
