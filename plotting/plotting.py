import matplotlib.pyplot as plt
import pandas
import numpy as np


def filter_data(data, variables):
    data_filtered = []
    data.columns = ["Col1", "Col2", "Col3", "Col4", "Col5", "Col6", "Col7", "Col8"]
    remove_str = ["report__unit__node__direction__stochastic_scenario_main_report__",
                  "report__connection__node__direction__stochastic_scenario_main_report__",
                  "__realization",
                  "__to_node"]

    # make sure that output file contains just 1 run (would be nice to change that in the future)
    number_of_runs = len(data["Col6"].unique())
    if number_of_runs != 1:
        raise ValueError("Found " + str(number_of_runs) + " runs in the output file (should be 1).")

    # filter each variable type
    for variable in variables:
        print("Collecting all data for variable " + str(variable))
        data_new = data.query("Col5 == '" + str(variable) + "'")
        data_new = data_new.reset_index()  # make sure indexes pair with number of rows

        current_node = data_new.iloc[0, 2]
        values = {current_node: 0.0}

        for index, row in data_new.iterrows():
            if row["Col2"] == current_node:
                values[current_node] += row["Col7"]
            else:
                current_node = row["Col2"]
                values[current_node] = row["Col7"]

        # get rid of the ones that are 0 (might be interesting to see though...)
        # values = {x: y for x, y in values.items() if y != 0}

        for rem_str in remove_str:
            values = {k.replace(rem_str, ""): v for k, v in values.items()}
            values = {k: v for k, v in values.items() if ("from_node" not in k and "emissions" not in k)}

        data_filtered.append(values)

    return data_filtered


def plot_bar(data, variable, nodes):
    for node in nodes:
        node_flows = {}

        # remove unnecessary strings in relationship names
        for key in data:
            if "__" + node in key:
                new_key = key.replace(node, "")
                new_key = new_key.replace("to", "")
                new_key = new_key.replace("_", "")
                node_flows[new_key] = data[key]

        # sort lowest to highest and calculate relative values
        node_flows = dict(sorted(node_flows.items(), key=lambda item: item[1]))
        labels = list(node_flows.keys())
        values = list(node_flows.values())
        rel_values = np.array(values)
        total_value = rel_values.sum()
        if total_value != 0:
            rel_values /= total_value
            rel_values *= 100.  # relative values in %

        # plot
        fig1, ax1 = plt.subplots()

        # horizontal bar plot
        ax1.barh(labels, rel_values)

        # remove axes splines
        for s in ['top', 'bottom', 'left', 'right']:
            ax1.spines[s].set_visible(False)

        # remove x, y Ticks
        ax1.xaxis.set_ticks_position('none')
        ax1.yaxis.set_ticks_position('none')

        # add padding between axes and labels
        # ax1.xaxis.set_tick_params(pad=5)
        # ax1.yaxis.set_tick_params(pad=10)

        # grid
        # ax1.set_axisbelow(True)
        # ax1.grid(linestyle='-.', alpha=0.2)

        # show top values
        ax1.invert_yaxis()
        ax1.set_xlim([0, 100])

        # add annotation to bars
        idx = 0
        for i in ax1.patches:
            plt.text(i.get_width() + 0.01, i.get_y() + 0.5,
                     str(round(rel_values[idx], 1)) + "% (" + str(round(values[idx], -1)) + ")", fontsize=10)
            idx += 1

        # add plot title
        ax1.set_title(node + " - " + str(variable), loc='left')

        # tight layout
        plt.tight_layout()

        # save plot
        plt.savefig("plots/" + variable + "-" + node + ".png")
        # plt.show()


if __name__ == '__main__':
    nodes = ["BAL", "DEN", "FIN", "NOR", "SWE"]
    variables = ["unit_flow", "connection_flow"]

    csv_file = pandas.read_csv('data/main_output.csv')
    print("Filtering...")
    filtered_data = filter_data(csv_file, variables)

    print("Plotting...")
    for data, variable in zip(filtered_data, variables):
        plot_bar(data, variable, nodes)
