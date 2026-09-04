# ESP32 Edge Adapter — reference

The ESP32 is the Open Engineering **edge adapter** in this course. It is the
boundary where Open Engineering semantics become a device protocol.

## What the ESP32 understands

Actuator-level concepts only — never character semantics:

```
set-position      move the servo to a position
center            return to center
execute-motion    run a configured motion sequence
stop              halt motion
get-position      report current position
get-temperature   report temperature telemetry
get-status        report status / health
```

The ESP32 MUST NOT interpret `agreement`, `disagreement`, `happiness`,
`attention`, or `confusion`. Those belong at higher semantic layers. The ESP32
MUST NOT decide when PixStars should nod.

## The physical boundary

```
Open Engineering
     ↓
ESP32 edge adapter
     ↓
electrical interface
     ↓
74HCT245
     ↓
AX-12A
```

The 74HCT245 is **purely physical communication**. It is where abstractions
cross a hardware boundary where voltage levels, buses, and electrical
communication matter. It never appears as a semantic Open Engineering entity in
this course.

## Reciprocating (half-duplex) serial

The AX-12A uses Dynamixel Protocol 1.0 over a half-duplex UART. The ESP32
controls **communication direction** on the shared line (transmit vs receive).
This direction management is one of the ESP32's explicit responsibilities.

## Conversion responsibility

The ESP32 receives a command such as `nod` and is responsible for producing the
Dynamixel Protocol 1.0 packets (instruction/status packets, register addresses,
checksums) that realize it. The `nod` sequence itself is decided at the
semantic layer (see `rules/nod-gesture.yaml`); the ESP32 executes the lower
level.

## Safety responsibilities

- Enforce configured safe limits even at the edge (defense in depth).
- Enforce the command timeout.
- Support an emergency stop.
- Report actuator state, errors, and connectivity upward as telemetry.
- Boot to a safe startup state; return to center before shutdown.

## Connectivity

The ESP32 connects to the Open Engineering runtime over the LAN/Wi-Fi (edge
adapter → event transport). Transport details (e.g. MQTT) stay below the
semantic event layer so the semantic architecture never couples to a specific
transport or topic naming.

## Health

The ESP32 exposes health information (connectivity, last communication,
error state) so the digital twin's `connected` and `lastCommandStatus` fields
can be kept honest.
