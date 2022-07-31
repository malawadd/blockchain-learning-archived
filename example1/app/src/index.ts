import * as p5 from 'p5';
import { connect } from "@tableland/sdk";

// The points from tableland we'll need to render
let points: Array<{x: number, y: number, id: Number}> = [];
// The current token id. pulled from http://url/#{id}
let tokenId = +window.location.hash.substr(1).replace("/", "")
// Some anchors in the canvas to help offset and scale the points
let anchors: Array<number> = [];
// A function we call on each canvas render or resize to recalc anchors
const updateAnchors = (w: number, h: number) => {
    let dmin = Math.min(w, h) - 8; // 8 just gives some buffer
    // How to scale raw x,y for our token. recall, x & y are between 0 and 512.
    let scalar = dmin / 512;
    anchors = [
        (w / 2), // Screen midpoint
        (h / 2), // Screen midpoint
        scalar
    ]
}

export const sketch = (p: p5) => {
    p.windowResized = () => {
        updateAnchors(window.innerWidth, window.innerHeight);
        p.resizeCanvas(window.innerWidth, window.innerHeight);
    }
    p.setup = () => {
        updateAnchors(window.innerWidth, window.innerHeight);
        p.createCanvas(window.innerWidth, window.innerHeight);
    
        // Connect to the Tableland network
        connect({ network: "testnet" })
        .then(connection => {
            // Run a SQL select on our project table
            return connection.read("select * from canvas_5_4")
        })
        .then(data => {
            // Format and store our data in the points[] array
            points = data.rows
            .map((d, id) => ({x: d[2], y: d[3], id}))
        })
    }
    

    p.draw = () => {
        // black background
        p.background(0);
        for (let pt of points) {
            // Magenta
            p.fill(255, 51, 255, 155);
            if (pt.id === tokenId) {
                // Aqua
                p.fill(0, 178, 255, 211);
            }
            p.noStroke();
            // Use the anchor and scalar to render a square space
            let nx = ((pt.x - 256) * anchors[2]) + anchors[0];
              let ny = ((pt.y - 256) * anchors[2]) + anchors[1];
            p.ellipse(nx, ny, 10 * anchors[2], 10 * anchors[2]);
      }
    }
}

export const myp5 = new p5(sketch, document.body);