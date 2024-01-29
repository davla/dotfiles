import asyncio

import i3ipc.aio


class ConnectionExtras(i3ipc.aio.Connection):
    """Add some extra features to i3ipc.aio.Connection"""

    async def events(self, *event_names):
        """Yield selected events from this i3 connection."""
        queue = asyncio.Queue()
        for event_name in event_names:
            self.on(event_name, lambda _, event: queue.put_nowait(event))
        while True:
            yield await queue.get()
