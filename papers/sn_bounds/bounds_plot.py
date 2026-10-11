"""Compare the pointwise bounds with OEIS A375865 through 28 wedges."""

from pathlib import Path

import matplotlib
import numpy as np
import oeis

matplotlib.use("Agg")
from matplotlib import pyplot as plt
from matplotlib.ticker import LogFormatterMathtext


def main() -> None:
    data = oeis.Sequence("A375865").data[:28]
    if len(data) != 28 or data[:4] != [1, 4, 16, 64] or data[23] != 13446591920995:
        raise ValueError("Expected OEIS A375865 counts for n=1,...,28, including S_24.")

    n = np.arange(1, 29)
    counts = np.asarray(data, dtype=np.float64)
    lower = 3.45056 ** (n - 1)
    upper = 2.95621 * 3.66179 ** (n - 1)
    if not np.all((lower <= counts) & (counts <= upper)):
        raise ValueError("The exact counts must lie between the pointwise bounds.")

    output = Path(__file__).resolve().with_suffix(".png")
    with plt.rc_context(
        {
            "font.family": "serif",
            "font.serif": ["STIXGeneral"],
            "mathtext.fontset": "stix",
            "font.size": 10,
            "axes.labelsize": 11,
            "axes.linewidth": 0.6,
            "xtick.labelsize": 9,
            "ytick.labelsize": 9,
            "legend.fontsize": 10,
        }
    ):
        fig, ax = plt.subplots(figsize=(6.0, 3.6), layout="constrained")
        ax.plot(
            n,
            lower,
            color="#0072B2",
            linestyle="--",
            linewidth=1.2,
            label=r"Lower bound: $(3.4505674)^{n-1}$",
        )
        ax.plot(
            n,
            counts,
            color="black",
            linewidth=0.9,
            marker="o",
            markersize=3.0,
            markerfacecolor="white",
            markeredgewidth=0.7,
            zorder=3,
            label=r"Exact count: $S_n$",
        )
        ax.plot(
            n,
            upper,
            color="#D55E00",
            linestyle="-.",
            linewidth=1.2,
            label=r"Upper bound: $2.95621(3.661786723)^{n-1}$",
        )
        ax.set_yscale("log")
        ax.set_xlabel(r"Number of wedges, $n$")
        ax.set_ylabel("Number of configurations (log scale)")
        ax.set_xlim(0.5, 28.5)
        ax.set_ylim(0.65, 1e16)
        ax.set_xticks([1, 4, 8, 12, 16, 20, 24, 28])
        ax.set_yticks(10.0 ** np.arange(0, 17, 2))
        ax.yaxis.set_major_formatter(LogFormatterMathtext())
        ax.minorticks_off()
        ax.tick_params(direction="out", length=3, width=0.6)
        ax.spines[["top", "right"]].set_visible(False)
        ax.grid(axis="y", color="0.88", linewidth=0.4)
        ax.set_axisbelow(True)
        ax.legend(loc="upper left", frameon=False, handlelength=3)
        fig.savefig(output, dpi=600, facecolor="white")
        plt.close(fig)

    print(f"Saved {output}")


if __name__ == "__main__":
    main()
